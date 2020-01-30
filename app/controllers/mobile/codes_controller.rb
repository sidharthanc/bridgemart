module Mobile
  class CodesController < BaseController
    class TokenError < StandardError; end
    rescue_from TokenError, with: -> { head 401 }
    respond_to :html, :pdf

    before_action :ensure_token_authentication_params

    def index
      @member = authenticate_with_token Member
      @codes = @member.codes.includes(:product_category)
    end

    def show
      @code = authenticate_with_token Code
      @member = @code.member
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{@code.member.organization.name}-#{@code.member.last_name}-#{@code.plan_product_category.name}",
            template: "mobile/codes/show.html.erb",
            layout: 'default.pdf'
        end
      end
    end

    private
      def ensure_token_authentication_params
        raise TokenError unless params[:id].present? && params[:token].present?
      end

      def token_authentication
        params[:token]
      end

      def authenticate_with_token(klass)
        klass.find(params[:id]).tap do |record|
          raise TokenError unless valid_token? record, params[:token]
        end
      end

      def valid_token?(record, token)
        Devise.secure_compare record.authentication_token, token
      end
  end
end
