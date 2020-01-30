class AddIndexesToPermissions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :permissions, %i[update_permitted target], algorithm: :concurrently
    add_index :permissions, %i[create_permitted target], algorithm: :concurrently
  end
end
