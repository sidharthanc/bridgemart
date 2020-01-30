module EML
  class Transaction
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
      def parse(json)
        new(
          id: json['system_transaction_id'],
          amount: json['amount'].to_money,
          timestamp: parse_timestamp(json['timestamp']),
          activity: json['activity'],
          reason: json['reason'],
          result: json['result'],
          notes: json['notes']
        )
      end

      def parse_timestamp(timestamp)
        ms_since_unix_epoch = /(?<timestamp>\d+)/.match(timestamp).values_at(:timestamp)[0].to_i
        Time.at(ms_since_unix_epoch / 1000.0).utc
      end
    end
  end
end
