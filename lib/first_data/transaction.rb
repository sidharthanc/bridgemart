module FirstData
  class Transaction
    PLACEHOLDER = '2400!placeholder'.freeze

    attr_accessor :id, :amount, :activity, :reason, :result, :notes, :timestamp

    def initialize(id:, amount:, timestamp:, activity: nil, reason: nil, result: nil, notes: nil)
      @id = id
      @amount = amount
      @timestamp = timestamp
      @activity = activity
      @reason = reason
      @result = result
      @notes = notes
    end

    class << self
      def parse(code, transaction)
        amount = code.limit_cents - transaction.fields[:new_balance].to_i
        reason = amount.zero? ? PLACEHOLDER : I18n.t('balance_discrepancy')

        # TODO: where's the spec for this?
        new(
          id: PLACEHOLDER,
          amount: amount,
          timestamp: Time.current,
          activity: PLACEHOLDER,
          reason: reason,
          result: PLACEHOLDER,
          notes: PLACEHOLDER
        )
      end
    end
  end
end
