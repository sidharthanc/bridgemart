module EML
  class RegisterCardJob < ::ApplicationJob
    include EML::Client

    COUNTRY = 'USA'.freeze

    def perform(code)
      @code = code
      @member = @code.member

      post register_url, params: registration_params_for_member
      @code.registered
    end

    private
      def register_url
        "cards/#{@code.card_number}/register"
      end

      def registration_params_for_member
        # Unlike others, this endpoint does _not_ expect location details to be in a 'location' block
        {
          first_name: @member.first_name,
          last_name: @member.last_name,
          address1: address_for_registration.street1,
          city: address_for_registration.city,
          state: address_for_registration.state,
          postal_code: address_for_registration.zip,
          country: COUNTRY,
          email: @member.email,
          client_tracking_id: @code.uuid
        }
      end

      def address_for_registration
        @member.address.present? ? @member.address : @code.organization.address
      end

      def every_code_for_member_has_been_registered?
        @member.reload.codes.all? { |code| code.registered? && !code.delivered? }
      end
  end
end
