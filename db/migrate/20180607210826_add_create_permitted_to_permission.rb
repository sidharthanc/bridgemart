class AddCreatePermittedToPermission < ActiveRecord::Migration[5.2]
  def change
    add_column :permissions, :create_permitted, :boolean, default: false, null: false
    Permission.update_permitted.update_all create_permitted: true
  end
end
