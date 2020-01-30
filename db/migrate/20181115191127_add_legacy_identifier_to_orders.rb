class AddLegacyIdentifierToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :legacy_identifier, :bigint, index: true
  end
end
