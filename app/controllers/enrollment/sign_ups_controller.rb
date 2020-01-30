module Enrollment
  class SignUpsController < Enrollment::BaseController
    include SignUpable
    before_action :set_order, only: %i[edit update]
    layout :select_layout, only: [:new]

    def new
      @sign_up = SignUp.new(organization: current_organization)
    end

    def create
      @sign_up = SignUp.new permitted_params
      if signed_in?
        re_enroll
      elsif @sign_up.save(context: :create)
        sign_in_and_invite_user(@sign_up)
      end
      respond_with @sign_up, location: -> { edit_enrollment_order_path(@sign_up.order) }
    end

    private
      def permitted_params
        params
          .require(:sign_up)
          .permit :first_name, :last_name, :email, :phone, :organization_name, :title,
                  :industry, :approx_employees_count, :approx_employees_with_safety_prescription_eyewear_count,
                  product_category_ids: []
      end

      def update_params
        params.require(:sign_up).permit product_category_ids: []
      end

      def set_order
        @order = Order.find params[:id]
        authorize @order, :edit?
      end

      def re_enroll
        @sign_up.user = current_organization.primary_user
        @sign_up.organization = current_organization
        @sign_up.save context: :re_enrollment
      end

      def select_layout
        current_user.present? && current_user.orders.has_members.present? ? "dashboard" : "application"
      end
  end
end
