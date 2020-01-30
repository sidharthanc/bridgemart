class AddStartsOnAndEndsOnToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :starts_on, :date
    add_column :orders, :ends_on, :date
  end
end
