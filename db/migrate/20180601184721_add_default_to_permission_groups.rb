class AddDefaultToPermissionGroups < ActiveRecord::Migration[5.2]
  def change
    change_table(:permission_groups) do |t|
      t.boolean :default, default: false, null: false
    end
  end
end
