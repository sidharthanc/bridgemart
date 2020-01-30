module ClosedLoop
  module Transactions
    class VoidReloadCard # 2801
      attr_reader :request
      delegate :perform, to: :request

      def initialize(card_number:, amount:, ean: nil)
        raise Request::MissingRequiredField, "EAN is required" if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION && ean.nil?

        @request = ClosedLoop::Request.new(transaction: :void_reload) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:alternate_merchant_number)
          request.add_field(:transaction_amount, amount)
          request.add_field(:embossed_card_number, card_number)
          request.add_field(:source_code)
          if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION
            request.add_field(:extended_account_number, ean)
            request.add_field(:merchant_key_id)
          end
          request.add_field(:echo, 'Taco')
        end
      end
    end
  end
end
