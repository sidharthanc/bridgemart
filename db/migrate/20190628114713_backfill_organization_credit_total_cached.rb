class BackfillOrganizationCreditTotalCached < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrganizationCreditTotalCached.perform_later
  end
end
