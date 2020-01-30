class AddTotalChargesCachedToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :total_charges_cached_cents, :integer
  end
end
