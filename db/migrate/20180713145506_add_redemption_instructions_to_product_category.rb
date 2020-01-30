class AddRedemptionInstructionsToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :redemption_instructions, :text
  end
end
