class AddInstructionsToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :default_redemption_instructions, :text
  end
end
