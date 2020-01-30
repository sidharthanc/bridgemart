module Backfill
  class OrderTotalFeesCached < ApplicationJob
    def perform
      Order.where(total_fees_cached_cents: nil).paid.find_each(batch_size: 100) do |order|
        order.update(total_fees_cached: order.total_fees)
      end
    end
  end
end
