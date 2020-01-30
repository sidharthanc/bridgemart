class BackfillTotalChargesCachedCentsToOrder < ActiveRecord::Migration[5.2]
  def change
    Backfill::OrderTotalChargesCached.perform_later
  end
end
