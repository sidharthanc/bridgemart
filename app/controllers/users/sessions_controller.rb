module Users
  class SessionsController < Devise::SessionsController
    layout "application"

    # POST /login
    def create
      if browser_not_supported_if_ie
        redirect_to root_path
      else
        super
      end
    end
  end
end
