class CreatePermissionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_groups do |t|
      t.string :name, null: false, default: ''
      t.boolean :admin, default: false
      t.timestamps
    end

    create_join_table :permission_groups, :users do |t|
      t.index :permission_group_id
      t.index :user_id
    end
  end
end
