class AddsTotalFeesCachedCentsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :total_fees_cached_cents, :integer
  end
end
