class AddsDefaultValueToIsCancelled < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :is_cancelled, :boolean, default: false
  end
end
