module Walmart
  class BatchTransactionHistoryJob < ApplicationJob
    queue_as :scheduled

    include WithProblems

    FIELD_ATTRIBUTES = %i[used_at visit_number store_number store_city store_state department_category upc_number upc_description amount_cents external_id].freeze
    DUPLICATE_CHECK_ATTRIBUTES = %i[used_at visit_number store_number store_city store_state upc_number upc_description amount_cents external_id].freeze
    Struct.new('UsageImport', *FIELD_ATTRIBUTES)

    def perform(usage_import)
      @problems = []
      code_ids = []

      with_downloaded(usage_import.file) do |file|
        Excel::Spreadsheet.new(file).each_with_index do |transaction, index|
          next if transaction.blank?

          import(transaction, index).tap do |usage|
            next if usage.nil?

            if usage.valid?
              code_ids << usage.code_id
            else
              @problems << problems_for(usage, index: index)
            end
          end
        end
      end

      usage_import.update problems: @problems
      FirstData::BatchBalanceInquiryJob.perform_later(code_ids.uniq)
    end

    def import(transaction, index)
      @usage = spreadsheet_to_usage(transaction) || spreadsheet_to_reload(transaction)
      @code = Code.find_by(external_id: @usage.external_id)

      unless @code
        @problems << "Code ID #{@usage.external_id} not found at row #{index}"
        return
      end

      if duplicate_usage?
        @problems << "Duplicate usage found at row #{index}"
        return
      end

      unless @usage.to_h[:amount_cents].zero?
        create_usage.tap do |usage|
          if usage&.valid?
            @code.deactivate if @code.single_use?
            @code.used
          end
        end
      end
    end

    private
      def spreadsheet_to_usage(transaction)
        return unless transaction.include? 'retail_price'

        Struct::UsageImport.new.tap do |usage|
          usage.used_at = transaction.fetch 'visit_date'
          usage.visit_number = transaction.fetch 'visit_nbr'

          usage.external_id = transaction.fetch 'card'

          usage.store_city = transaction.fetch 'store_city'
          usage.store_state = transaction.fetch 'store_state'
          usage.store_number = transaction.fetch 'store_nbr'

          usage.department_category = transaction.fetch 'catg'

          usage.upc_number = transaction.fetch 'upc_nbr'
          usage.upc_description = transaction.fetch 'upc_desc'

          usage.amount_cents = transaction.fetch('retail_price').to_f * 100.0
        end
      end

      def spreadsheet_to_reload(transaction)
        return unless transaction.include? 'reload_amt'

        Struct::UsageImport.new.tap do |usage|
          usage.used_at = transaction.fetch 'VISIT_DATE'
          usage.visit_number = transaction.fetch 'VISIT_NBR'

          usage.external_id = transaction.fetch 'card'

          usage.store_city = transaction.fetch 'store_city'
          usage.store_state = transaction.fetch 'store_state'
          usage.store_number = transaction.fetch 'STORE_NBR'

          usage.amount_cents = transaction.fetch('reload_amt').to_f * 100.0
        end
      end

      def create_usage
        @code.usages.create!(@usage.to_h)
      end

      def duplicate_usage?
        @code.usages.where(@usage.to_h.slice(*DUPLICATE_CHECK_ATTRIBUTES)).any?
      end

      def with_downloaded(attached)
        Tempfile.open(binmode: true) do |file|
          attached.download { |chunk| file.write(chunk) }
          file.rewind

          yield file
        end
      end
  end
end
