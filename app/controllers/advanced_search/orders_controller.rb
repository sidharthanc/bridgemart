module AdvancedSearch
  class OrdersController < ::DashboardController
    def new
      @search = Order.ransack(params[:q])
      @orders = @search.result
    end
  end
end
