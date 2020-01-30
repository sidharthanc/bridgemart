class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :plan
      t.monetize :amount
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
