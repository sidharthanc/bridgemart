class AddUuidToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :uuid, :uuid
  end
end
