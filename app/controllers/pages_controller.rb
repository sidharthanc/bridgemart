class PagesController < DashboardController
  layout 'application', only: :home
  authenticated! except: :home
  helper_method :show_extended_dashboard?

  def home; end

  def dashboard
    if requested_organization
      @dashboard = Dashboard::Organization.new(requested_organization)
    elsif current_user.managing_multiple_organizations?
      redirect_to(overview_index_path) && return
    elsif current_organization
      @dashboard = Dashboard::Organization.new(current_organization)
    else
      redirect_to(new_enrollment_sign_up_path) && return
    end
  end

  def terms_and_conditions
  end

  private
    def requested_organization
      return unless params[:organization_id].present?

      organization = Organization.find(params[:organization_id])
      authorize organization, :show?
      organization
    end

    def organization_orders
      @dashboard.orders.orders
    end

    def show_extended_dashboard?
      current_user.use_enhanced_dashboard?
    end
end
