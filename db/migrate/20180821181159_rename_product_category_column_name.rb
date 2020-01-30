class RenameProductCategoryColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :product_categories, :redemption_instructions, :product_description
  end
end
