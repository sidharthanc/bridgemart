class OverviewController < DashboardController
  authenticated!

  def index
    if current_user.managing_multiple_organizations?
      # @overview = Overview.new(current_user.multiple_organizations)
      redirect_to organizations_path
    else
      redirect_to dashboard_path
    end
  end
end
