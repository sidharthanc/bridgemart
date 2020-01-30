module Backfill
  class OrganizationAccountStatusCached < ApplicationJob
    def perform
      Organization.where(account_status_cached: nil).find_each(batch_size: 50, &:update_account_status_cached)
    end
  end
end
