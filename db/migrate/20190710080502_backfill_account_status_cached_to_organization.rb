class BackfillAccountStatusCachedToOrganization < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrganizationAccountStatusCached.perform_later
  end
end
