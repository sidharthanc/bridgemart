module Backfill
  class OrganizationUsageTotalCached < ApplicationJob
    def perform
      Organization.where(usage_total_cached_cents: nil).find_each(batch_size: 50) do |organization|
        organization.update(usage_total_cached: organization.usage_total)
      end
    end
  end
end
