class AddMembersCountToOrders < ActiveRecord::Migration[5.2]
  def self.up
    add_column :orders, :members_count, :integer
  end

  def self.down
    remove_column :orders, :members_count
  end
end
