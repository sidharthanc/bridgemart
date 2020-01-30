class AddDeactivatedAtToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :deactivated_at, :datetime
  end
end
