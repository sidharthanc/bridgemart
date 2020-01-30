class AddDeactivatedAtToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :deactivated_at, :datetime
  end
end
