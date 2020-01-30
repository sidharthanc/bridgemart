class CreatePermissionGroupOwnerships < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_group_ownerships do |t|
      t.references :permission_group, index: true
      t.references :owner, index: true

      t.timestamps
    end
  end
end
