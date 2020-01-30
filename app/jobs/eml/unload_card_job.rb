module EML
  class UnloadCardJob < ::ApplicationJob
    include EML::Client
    include MoneyRails::ActionViewExtension

    COUNTRY = 'USA'.freeze

    def perform(code, amount)
      return if code.deactivated_at.present?

      @code = code
      @amount = amount
      @member = @code.member
      begin
        post "cards/#{@code.card_number}/unload", params: code_unload_params
      rescue EML::Error => e
        raise unless e.message =~ /was not found/  # Already removed?
      end
      @code.unloaded @amount.to_money
    end

    private
      def code_unload_params
        {
          amount: @amount,
          note: generate_note(@amount),
          location: {
            state: address_for_registration.state,
            country: COUNTRY
          },
          client_tracking_id: @code.uuid
        }
      end

      def address_for_registration
        @member.address.present? ? @member.address : @code.organization.address
      end

      def generate_note(amount)
        "Unload #{humanized_money_with_symbol(amount, no_cents_if_whole: false)}"
      end
  end
end
