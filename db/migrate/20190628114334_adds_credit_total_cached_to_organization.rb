class AddsCreditTotalCachedToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :credit_total_cached_cents, :integer
  end
end
