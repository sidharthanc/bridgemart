class MovePaymentFieldsToTokens < ActiveRecord::Migration[5.2]
  def change
    rename_column :payment_methods, :credit_card_number, :credit_card_token
    rename_column :payment_methods, :ach_account_number, :ach_account_token
  end
end
