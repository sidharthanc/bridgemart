class AddsBackfillOrderTotalFeesCached < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrderTotalFeesCached.perform_later
  end
end
