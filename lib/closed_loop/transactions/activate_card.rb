module ClosedLoop
  module Transactions
    class ActivateCard
      attr_reader :id, :limit, :organization_id
      attr_reader :request
      delegate :perform, to: :request

      def initialize(id:, limit:, organization_id:, card_number: nil, ean: nil)
        @request = ClosedLoop::Request.new(transaction: :activate_virtual_card) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:alternate_merchant_number)
          request.add_field(:source_code)
          request.add_field(:promotion_code)
          request.add_field(:transaction_number, id)
          request.add_field(:transaction_amount, limit)
          request.add_field(:reference_number, organization_id)
          request.add_field(:local_currency)
          if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION
            request.add_field(:merchant_key_id)
            request.add_field(:embossed_card_number, card_number) if card_number.present?
            request.add_field(:extended_account_number, ean) if ean.present?
          end
          request.add_field(:echo, 'Taco')
        end
      end
    end
  end
end
