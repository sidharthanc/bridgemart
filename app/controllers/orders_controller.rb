class OrdersController < DashboardController
  include Ransackable
  before_action only: :index do
    adjust_ransack_date_range_for_attribute(params, :created_at)
  end
  before_action :set_order, only: [:cancel]

  def show
    @dashboard = Dashboard::Organization.new current_organization
    @order = current_organization.orders.find(params[:id])
    authorize @order
    @plan = @order.plan
  end

  def cancel
    @order.cancel
    redirect_to organization_orders_path(current_organization)
  end

  def index
    params[:q] ||= {}
    if params[:q][:created_at_between].present?
      dates_arr = params[:q][:created_at_between].split(",")
      params[:q][:created_at_between] = [dates_arr.first.to_date.beginning_of_day, dates_arr.last.to_date.end_of_day].join(",")
    end
    @search = current_organization.orders.includes(:members).has_members.with_attached_pdf.ransack(params[:q])
    @search.sorts = 'created_at DESC' if @search.sorts.empty?

    respond_to do |format|
      format.html do
        @pagy, @orders = paginate @search.result.chronological
        @orders_count = @search.result.size
      end

      format.csv do
        @orders = current_organization.orders.includes(:line_items).has_members.order('created_at DESC')
        send_data @orders.to_csv, filename: "orders-#{DateTime.current}.csv"
      end
    end
  end

  private

    def set_order
      @order = current_organization.orders.find(params[:order_id])
    end
end
