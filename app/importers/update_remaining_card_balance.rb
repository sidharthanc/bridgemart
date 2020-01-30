require 'csv'

class UpdateRemainingCardBalance < Importer
  def initialize(filepath)
    super
  end

  def import
    log_header
    import_records # Transaction lock only at the row level, not the table
  ensure
    log_footer
  end

  private
    def create_schema_records(record)
      @record = record
      update_remaining_card_balance
    end

    def update_remaining_card_balance
      balance = remaining_balance
      return if balance.zero?

      @code = Code.find_by! legacy_identifier: card_id
      if @code.balance.zero?
        @code.update balance: balance.to_money
      else
        log_exception RuntimeError.new("Code ID #{@code.id} of Order #{@code.order.id} does not have a zero balance"), @record
      end
    end

    def remaining_balance
      @record.fetch('Remaining Balance').to_f
    end

    def card_id
      @record.fetch('Card ID')
    end
end
