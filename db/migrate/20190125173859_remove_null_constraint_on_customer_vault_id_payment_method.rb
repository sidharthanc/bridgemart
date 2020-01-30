class RemoveNullConstraintOnCustomerVaultIdPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    change_column_null :payment_methods, :customer_vault_id, true
  end
end
