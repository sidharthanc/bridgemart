module ClosedLoop
  module Transactions
    class AssignMerchantKey
      attr_reader :request
      delegate :perform, to: :request

      def initialize(key_id: rand(999), merchant_key: FirstData::Client.credentials[:merchant_working_key_encrypted])
        @request = ClosedLoop::Request.new(transaction: :assign_merchant_working_key) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:merchant_key, merchant_key)
          request.add_field(:transaction_number, rand(999_999))
          request.add_field(:echo, 'Taco')
          # Just a lil bit hacky
          # This is the source code, which cannot be with EAN for this transaction
          fields = request.instance_variable_get(:@fields)
          fields << ['EA', 31]
          fields << ['F3', key_id]
          request.instance_variable_set(:@fields, fields)
        end
        puts "Using merchant key #{key_id}" if defined?(Rails::Console)
      end
    end
  end
end
