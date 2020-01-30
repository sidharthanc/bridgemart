module ClosedLoop
  module Transactions
    class BalanceInquiry # 2400
      attr_reader :request
      delegate :perform, to: :request

      def initialize(card_number:, ean: nil)
        raise ArgumentError, "EAN is required" if ClosedLoop.using_merchant_key? && ean.nil?

        @request = ClosedLoop::Request.new(transaction: :balance) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:alternate_merchant_number)
          request.add_field(:embossed_card_number, card_number)
          request.add_field(:merchant_and_terminal_id)
          if ClosedLoop.using_merchant_key?
            request.add_field(:extended_account_number, ean)
            request.add_field(:merchant_key_id)
          end
          request.add_field(:source_code)
        end
      end
    end
  end
end
