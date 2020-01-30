module Backfill
  class OrganizationCreditTotalCached < ApplicationJob
    def perform
      Organization.where(credit_total_cached_cents: nil).find_each(batch_size: 50, &:credit_total)
    end
  end
end
