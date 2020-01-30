class Broker::SignUpsController < Enrollment::SignUpsController
  layout :select_layout, only: %i[create]

  def create
    @sign_up = BrokerSignUp.new(permitted_params.merge(multi_org_user: current_user))
    if current_organization
      re_enroll
    else
      sign_in_and_invite_user(@sign_up) if @sign_up.save && !primary_contact_manages_muliple_orgs?(@sign_up.email)
    end
    respond_with @sign_up, location: -> { edit_enrollment_order_path(@sign_up.order, organization_id: current_organization&.id) }
  end

  protected
    helper_method def current_organization
      return super unless current_user&.managing_multiple_organizations?

      organization = ::Organization.find_by(id: params.dig(:sign_up, :organization_id)) || ::Organization.find_by(id: params.dig(:broker_sign_up, :organization_id))
      return unless organization

      authorize organization, :edit?
      @current_organization ||= organization
    end

  private
    def permitted_params
      return super if params[:sign_up]

      params.require(:broker_sign_up).permit :first_name, :last_name, :email,
                                             :title, :phone, :organization_name, :industry, :approx_employees_count,
                                             :approx_employees_with_safety_prescription_eyewear_count,
                                             product_category_ids: []
    end

    def primary_contact_manages_muliple_orgs?(email)
      user = User.find_by(email: email)
      user&.managing_multiple_organizations?
    end

    def select_layout
      current_user.present? && current_user.orders.has_members.present? ? "dashboard" : "application"
    end
end
