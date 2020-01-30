class SetLegacyProcessedAtOnOrder < ActiveRecord::Migration[5.2]
  def change
    Order.where(processed_at: nil).where.not(paid_at: nil).update_all('processed_at = paid_at')
  end
end
