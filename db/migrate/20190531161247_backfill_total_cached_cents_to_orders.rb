class BackfillTotalCachedCentsToOrders < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrderTotalCached.perform_later
  end
end
