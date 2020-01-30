class PlansController < DashboardController
  def index
    @plans = current_organization.plans
  end
end
