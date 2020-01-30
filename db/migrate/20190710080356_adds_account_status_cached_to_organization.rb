class AddsAccountStatusCachedToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :account_status_cached, :string
  end
end
