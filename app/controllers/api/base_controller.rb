module API
  class BaseController < ActionController::API
    respond_to :json

    before_action -> { warden.authenticate!(:organization_access_token, :database_authenticatable) }

    def verify
      if current_user
        render plain: 'OK'
      else
        head :unauthorized
      end
    end
  end
end
