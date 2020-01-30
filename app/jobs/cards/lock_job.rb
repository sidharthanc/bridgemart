module Cards
  class LockJob < ::ApplicationJob
    def perform(code, reason)
      return unless code&.uses_provider? && code&.card_provider

      code.card_provider.lock(reason)
      code.touch(:locked_at)
    end
  end
end
