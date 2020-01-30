class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  respond_to :html

  include Pundit
  include Paginable
  include Memoizer
  include Pagy::Backend

  rescue_from Pundit::NotAuthorizedError, with: :access_denied

  helper_method :current_organization
  helper_method :navigation

  before_action :browser_not_supported_if_ie

  def current_organization
    return unless current_user
    return if params[:skip_current_organization]

    if params[:organization_id].present?
      policy_scope(Organization).find(params[:organization_id])
    elsif session[:current_organization_id].present?
      begin
        policy_scope(Organization).find(session[:current_organization_id])
       rescue ActiveRecord::RecordNotFound
        return
       end

    else
      policy_scope(Organization).take
    end
  end
  memoize :current_organization

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path # Redirect to login page
  end

  def self.authenticated!(options = {})
    before_action :authenticate_user!, options
  end

  def self.unauthenticated!(options = {})
    skip_before_action :authenticate_user!, options
  end

  def authorized(collection)
    policy_scope collection
  end

  def access_denied(_operation)
    flash[:alert] = t 'errors.access_denied'
    redirect_to root_path
  end

  def browser_not_supported_if_ie
    if browser_not_supported?
      flash.now[:alert] = "This site does not support Internet Explorer. Please use Microsoft Edge, Google Chrome, Apple Safari, or Mozilla Firefox."
      return true
    end
    false
  end

  def browser_not_supported?
    user_agent = request.env.fetch('HTTP_USER_AGENT', '').downcase
    user_agent.index('msie') && !user_agent.index('opera') && !user_agent.index('webtv')
  end
end
