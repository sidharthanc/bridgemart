class AddImageNameToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :image_name, :integer, default: 0
  end
end
