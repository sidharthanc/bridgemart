class RemoveImageNameFromProductCategory < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_categories, :image_name
  end
end
