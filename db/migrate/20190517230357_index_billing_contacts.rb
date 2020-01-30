class IndexBillingContacts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :billing_contacts, %i[billable_id billable_type], algorithm: :concurrently
  end
end
