class SetUnloadedCentsDefaultOnCodes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :codes, :unloaded_amount_cents, from: nil, to: 0
  end
end
