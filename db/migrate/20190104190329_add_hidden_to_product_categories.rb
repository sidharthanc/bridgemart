class AddHiddenToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :hidden, :integer, default: 0 # visible
  end
end
