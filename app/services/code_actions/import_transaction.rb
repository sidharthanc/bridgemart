module CodeActions
  class ImportTransaction
    attr_reader :code, :transaction

    def initialize(code:, transaction:)
      @code = code
      @transaction = transaction
    end

    def import
      create_usage.tap do |usage|
        unless usage.amount_cents.zero?
          if usage.save
            code.deactivate if code.single_use?
            code.used
          end
        end
      end
    end

    private
      def create_usage
        Usage.find_or_initialize_by(external_id: transaction.id) do |usage|
          usage.code = code
          usage.amount = transaction.amount
          usage.activity = transaction.activity
          usage.reason = transaction.reason
          usage.result = transaction.result
          usage.notes = transaction.notes
          usage.used_at = transaction.timestamp
        end
      end
  end
end
