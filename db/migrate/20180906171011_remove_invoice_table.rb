class RemoveInvoiceTable < ActiveRecord::Migration[5.2]
  def up
    add_monetize :orders, :amount
    add_column :orders, :paid, :boolean, default: false

    drop_table :invoices
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Order hasn't referenced Invoice in ages"
  end
end
