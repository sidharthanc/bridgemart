class AddHasRedemptionInstructionsToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :has_redemption_instructions, :boolean, default: false
  end
end
