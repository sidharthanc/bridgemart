class AddTransactionNumberToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :transaction_number, :string
  end
end
