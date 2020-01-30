class CreateOrderStatistics < ActiveRecord::Migration[5.2]
  def change
    create_view :order_statistics
  end
end
