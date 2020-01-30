class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.references :permission_group, null: false
      t.string :target, null: false
      t.boolean :update_permitted, default: false
      t.timestamps
    end
  end
end
