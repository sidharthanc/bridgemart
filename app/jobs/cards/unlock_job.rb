module Cards
  class UnlockJob < ::ApplicationJob
    def perform(code, reason)
      return unless code&.uses_provider? && code&.card_provider

      code.card_provider.unlock(reason)
    end
  end
end
