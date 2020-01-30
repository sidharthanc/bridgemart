class AddInvoiceSentAtToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :invoice_sent_at, :datetime
  end
end
