module Backfill
  class OrderTotalChargesCached < ApplicationJob
    def perform
      Order.where(total_charges_cached_cents: nil).paid.find_in_batches(batch_size: 100) do |orders|
        orders.each do |order|
          order.update(total_charges_cached: order.total_charges)
        end
      end
    end
  end
end
