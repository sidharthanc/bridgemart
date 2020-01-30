class AddAppliedCreditToOrder < ActiveRecord::Migration[5.2]
  def change
    change_table(:orders) do |t|
      t.monetize :applied_credit
    end
  end
end
