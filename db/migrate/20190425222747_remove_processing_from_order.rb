class RemoveProcessingFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :processing
  end
end
