class AddProductBinToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :product_bin, :string
  end
end
