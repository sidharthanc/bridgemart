module EML
  class Card
    include ActiveModel::Model
    attr_accessor :code, :id, :balance, :status, :fields, :pan

    def self.from_code(code)
      new(code: code, id: code.card_number, balance: code.balance, status: code.status, fields: code.fields, pan: code.pan)
    end

    def activate
      EML::ActivateCardJob.perform_now code
    end

    def register
      EML::RegisterCardJob.perform_now code
    end

    def lock(reason)
      EML::LockCardJob.perform_now code, reason.to_s
    end

    def unlock(_reason)
      EML::UnlockCardJob.perform_now code
    end

    def unload(amount)
      EML::UnloadCardJob.perform_now code, amount.to_d
    end
  end
end
