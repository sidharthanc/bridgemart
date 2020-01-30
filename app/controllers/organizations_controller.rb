class OrganizationsController < DashboardController
  include Ransackable

  def index
    @search = if current_user.admin? && params[:q].nil?
                policy_scope(Organization.none).ransack(params[:q])
              else
                policy_scope(Organization.all).ransack(params[:q])
              end

    @search.sorts = 'created_at DESC' if @search.sorts.empty?
    @pagy, @organizations = paginate @search.result
  end

  def show
    if find_organization
      unmemoize(:current_organization)
      session[:current_organization_id] = find_organization.try(:id)
      redirect_to dashboard_path(organization_id: find_organization.try(:id))
    end
  end

  def codes
    @organization = find_organization
    @search = Code.code_status(params[:code_status]).joins(:organization).where(organizations: { id: @organization.id }).includes(:order, :product_category, :usages).ransack(params[:q])
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @pagy, @codes = pagy(authorized(@search.result), link_extra: 'data-remote="true"')
  end

  private
    def find_organization
      organization = Organization.find(params[:id])
      authorize organization, :show?
      organization
    end
    memoize :find_organization
end
