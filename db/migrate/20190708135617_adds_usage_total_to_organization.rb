class AddsUsageTotalToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :usage_total_cached_cents, :integer
  end
end
