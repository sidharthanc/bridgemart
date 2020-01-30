module ClosedLoop
  module Transactions
    class TransactionHistory # 2400
      attr_reader :request

      def initialize(card_number:, ean: nil)
        raise Request::MissingRequiredField, "EAN is required" if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION && ean.nil?

        @request = ClosedLoop::Request.new(transaction: :transaction_history) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:source_code)
          request.add_field(:embossed_card_number, card_number)
          if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION
            request.add_field(:extended_account_number, ean)
            request.add_field(:merchant_key_id)
          end
          request.add_field(:transaction_number, rand(999_999))
          request.add_field(:history_format)
        end
      end

      def perform
        # TODO: Break down the payload into an easily consumable
        # format, maybe an array of transactions?
        request.perform
      end
    end
  end
end
