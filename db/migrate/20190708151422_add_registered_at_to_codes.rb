class AddRegisteredAtToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :registered_at, :datetime
  end
end
