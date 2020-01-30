class SetRedemptionInstructionFalseAsDefault < ActiveRecord::Migration[5.2]
  def change
    change_column :redemption_instructions, :active, :boolean, default: false
  end
end
