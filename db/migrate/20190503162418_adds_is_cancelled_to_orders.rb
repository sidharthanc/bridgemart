class AddsIsCancelledToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :is_cancelled, :boolean
  end
end
