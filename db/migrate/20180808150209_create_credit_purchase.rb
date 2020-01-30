class CreateCreditPurchase < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_purchases do |t|
      t.datetime :paid_at
      t.datetime :voided_at
      t.string :po_number
      t.string :error_message
      t.boolean :processing, default: false
      t.monetize :amount

      t.references :organization
      t.references :payment_method
      t.timestamps
    end
  end
end
