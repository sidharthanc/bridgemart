class BackfillUsageTotalCentsToOrganization < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrganizationUsageTotalCached.perform_later
  end
end
