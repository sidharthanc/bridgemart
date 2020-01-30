class CreateOrderProcessedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :processed_at, :datetime
  end
end
