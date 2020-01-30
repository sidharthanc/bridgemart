class BackfillStartsOnExpiresOnToCodes < ActiveRecord::Migration[5.2]
  def change
    Backfill::CodeExpiresStartsOn.perform_later
  end
end
