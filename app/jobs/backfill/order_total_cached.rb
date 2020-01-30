module Backfill
  class OrderTotalCached < ApplicationJob
    def perform
      Order.select(:id).find_in_batches.with_index do |records, index|
        puts "Processing batch #{index + 1}\r"
        Order.where(id: records).paid.each do |order|
          order.update(total_cached: order.total)
        end
      end
    end
  end
end
