class ChangeCustomerVaultIdTypeInPlan < ActiveRecord::Migration[5.2]
  def change
    change_column :plans, :customer_vault_id, :string
  end
end
