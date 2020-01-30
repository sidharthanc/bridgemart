module Cards
  class RegisterJob < ::ApplicationJob
    def perform(code)
      return unless code&.uses_provider? && code&.card_provider

      code.card_provider.register
      code.touch(:registered_at)
    end
  end
end
