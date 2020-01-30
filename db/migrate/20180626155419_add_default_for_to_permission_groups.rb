class AddDefaultForToPermissionGroups < ActiveRecord::Migration[5.2]
  def self.up
    add_column :permission_groups, :default_for, :integer, default: 0

    PermissionGroup.default.find_each do |permission_group|
      permission_group.update!(default_for: :organization)
    end
  end

  def self.down
    remove_column :permission_groups, :default_for, :integer, default: 0
  end
end
