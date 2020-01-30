class AddStartedAtToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :started_at, :datetime
  end
end
