class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def up
    make_payment_methods

    Order.find_each do |order|
      order.create_payment_method(customer_vault_id: order.customer_vault_id)
    end

    remove_column :orders, :customer_vault_id, :string
  end

  def down
    add_column :orders, :customer_vault_id, :string

    Order.find_each do |order|
      order.update(customer_vault_id: order.payment_method.customer_vault_id) if order.payment_method
    end

    revert { make_payment_methods }
  end

  def make_payment_methods
    create_table :payment_methods do |t|
      t.references :organization
      t.string :customer_vault_id, null: false, index: true
      t.string :billing_id
      t.string :ach_account_name
      t.string :ach_account_number
      t.string :ach_account_type
      t.string :credit_card_number
      t.string :credit_card_expiration_date
      t.timestamps
    end

    add_reference :orders, :payment_method, index: true
  end
end
