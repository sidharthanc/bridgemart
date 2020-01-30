module Cards
  class ActivateJob < ::ApplicationJob
    def perform(code)
      return unless code&.uses_provider? && code&.card_provider
      return if code.card_number.present? || code.limit.zero?

      code.card_provider.activate
    end
  end
end
