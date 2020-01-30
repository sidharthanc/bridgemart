class AddGeneratedAtToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :generated_at, :datetime
  end
end
