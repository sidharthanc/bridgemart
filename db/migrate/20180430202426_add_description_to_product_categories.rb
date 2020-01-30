class AddDescriptionToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :description, :text
  end
end
