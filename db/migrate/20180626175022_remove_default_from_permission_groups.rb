class RemoveDefaultFromPermissionGroups < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :permission_groups, :default, :boolean, default: false
  end

  def self.down
    add_column :permission_groups, :default, :boolean, default: false
  end
end
