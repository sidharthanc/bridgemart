module Devise
  module Strategies
    class OrganizationToken < Base
      def valid?
        request.headers['API_KEY'].present?
      end

      def authenticate!
        # NON-standard HTTP headers (with 'X-') get 'HTTP_' prepended and dashes turn to underscores!
        organization_token = request.headers['API_KEY'].presence
        organization       = organization_token && Organization.find_by(authentication_token: organization_token.to_s)
        # We should create a 'user' for the org to use, but for now, it will be primary user
        if organization
          user = organization.primary_user.presence 
          # Notice we are passing store false, so the user is not
          # actually stored in the session and a token is needed
          # for every request. If you want the token to work as a
          # sign in token, you can simply remove store: false.
          if user
            success!(user)
          else
            # Fail and halt (valid? makes sure non-org token request don't end here)
            fail!("Invalid Organization Token")
          end
        else
          fail!("Invalid Organization Token")
        end
      end
    end
  end
end
