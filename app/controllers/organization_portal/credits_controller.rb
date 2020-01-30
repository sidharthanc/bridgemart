class OrganizationPortal::CreditsController < OrganizationPortalController
  before_action :set_organization
  before_action :build_search, only: %i[index advanced_search]

  def index
    @pagy, @history = paginate @search.result
  end

  def advanced_search
    @pagy, @history = paginate @search.result
  end

  def export
    credits = @organization.credits
    authorize credits
    respond_with credits do |format|
      format.csv do
        send_data credits.to_csv, filename: "credit-#{Date.current}.csv"
      end
    end
  end

  private
    def build_search
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q] && params[:q][:created_at_lteq].present?

      @search = @organization.credits.includes(:organization, :source).ransack(params[:q])
      @search.sorts = 'created_at desc' if @search.sorts.empty?
    end

    def set_organization
      @organization = current_organization
    end
end
