module Cards
  class UnloadJob < ::ApplicationJob
    def perform(code, amount)
      return if !(code&.uses_provider? && code&.card_provider) || code&.inactive? || code.balance.zero?

      code.card_provider.unload(amount.to_money)
      MemberMailer.new.deactivate_code(code)
    end
  end
end
