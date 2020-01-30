module ClosedLoop
  class Card
    include ActiveModel::Model
    attr_accessor :code, :id, :balance, :status, :fields , :pan
    class UnloadAmountGreaterThanBalance < StandardError; end
    class UnloadAmountDoesntMatchRequest < StandardError; end

    def self.from_code(code)
      new(code: code, id: code.external_id, balance: code.balance, status: code.status, fields: code.fields, pan: nil)
    end

    def activate
      code.update status: :activating

      response = ClosedLoop::Transactions::ActivateCard.new(id: code.id,
                                                            limit: code.limit_cents,
                                                            organization_id: code.member.organization.id)
                                                       .perform
      if response.success?
        unless response.fields[:new_balance] == code.limit_cents.to_s
          ClosedLoop::Transactions::VoidActivateCard.new(card_number: response.fields[:embossed_card_number], ean: response.fields[:extended_account_number], amount: code.limit_cents)
          raise "Balance did not match requested amount"
        end
        self.id = response.fields[:embossed_card_number]
        self.balance = Money.new(response.fields[:new_balance], "USD")
        self.fields = response.fields.stringify_keys # Save the rest of the fields for later use
        code.activated self
      else
        raise "Closed Loop Card Activation Failed: #{response.error_message}"
      end
    end

    # FirstData/ClosedLoop does not require registration
    def register
      code.registered
    end

    def lock(reason)
      return unless code.card_number && code.pin

      response = ClosedLoop::Transactions::LockCard.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin), reason: reason).perform
      code.locked if response.success?
    end

    def unlock(reason)
      return unless code.card_number && code.pin

      response = ClosedLoop::Transactions::UnlockCard.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin), reason: reason).perform
      code.registered if response.success?
    end

    def transaction_history
      return unless code.card_number && code.pin

      response = ClosedLoop::Transactions::TransactionHistory.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin)).perform
      response.fields if response.success?
    end

    def unload(_requested_amount) # requested_amount is ignored for FD
      return unless code.card_number && code.pin

      # ClosedLoop does not support unload amounts, it is all or nothing
      response = ClosedLoop::Transactions::CloseCard.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin)).perform
      if response.success?
        code.unloaded((response.fields[:previous_balance].to_f / 100).to_money)
      else
        raise response.error_message
      end
    end
  end
end
