module ClosedLoop
  module Transactions
    class LockCard # 2003
      attr_reader :request
      delegate :perform, to: :request

      TRANSACTIONS = {
        lock: :freeze_active_card,
        unlock: :unfreeze_active_card
      }.freeze

      def initialize(card_number:, action: :lock, reason: nil, ean: nil)
        raise Request::MissingRequiredField, "EAN is required" if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION && ean.nil?
        return unless TRANSACTIONS[action]

        @request = ClosedLoop::Request.new(transaction: TRANSACTIONS[action]) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:alternate_merchant_number)
          request.add_field(:source_code)
          request.add_field(:embossed_card_number, card_number)
          if ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION
            request.add_field(:extended_account_number, ean)
            request.add_field(:merchant_key_id)
          end
          request.add_field(:notes, reason) if reason.present?
          request.add_field(:echo, 'Taco')
        end
      end
    end
  end
end
