class AddLockedAtToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :locked_at, :datetime
  end
end
