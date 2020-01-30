class RenameHasRedemptionInstructionsInProductCategory < ActiveRecord::Migration[5.2]
  def change
    rename_column :product_categories, :has_redemption_instructions, :redemption_instructions_editable
  end
end
