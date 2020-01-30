module FirstData
  class BalanceInquiryJob < ::ApplicationJob
    queue_as :low

    def perform(code)
      return unless code.active?

      response = ::ClosedLoop::Transactions::BalanceInquiry.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin)).perform
      if response.fields[:response_code] == '02' # account is closed
        # TODO: If there is a balance, likely want to mark these as pending deactivating, right?
        code.update(balance_cents: response.fields[:new_balance], status: :deactivated)
      elsif response.success? && response.fields[:new_balance].present?
        if code.balance_cents != response.fields[:new_balance]
          code.update(balance_cents: response.fields[:new_balance])
          code.update(status: code.detect_status_based_on_balance)
        end
      end
    end
  end
end
