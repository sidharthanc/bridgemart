class AddCustomerVaultIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :customer_vault_id, :string
  end
end
