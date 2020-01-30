module ClosedLoop
  module Transactions
    class ActivatePhysicalCard
      attr_reader :id, :amount, :organization_id
      attr_reader :request
      delegate :perform, to: :request

      def initialize(id:, amount:, card_number:, ean: nil, organization_id: nil)
        @request = ClosedLoop::Request.new(transaction: :activate_physical_card) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:alternate_merchant_number)
          request.add_field(:source_code)
          request.add_field(:promotion_code)
          request.add_field(:transaction_number, id)
          request.add_field(:transaction_amount, amount)
          request.add_field(:reference_number, organization_id) if organization_id.present?
          request.add_field(:local_currency)
          request.add_field(:embossed_card_number, card_number)
          if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION
            request.add_field(:merchant_key_id)
            request.add_field(:extended_account_number, ean) if ean.present?
          end
          request.add_field(:echo, 'Taco')
        end
      end
    end
  end
end
