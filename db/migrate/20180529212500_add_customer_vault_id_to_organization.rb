class AddCustomerVaultIdToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :customer_vault_id, :integer
  end
end
