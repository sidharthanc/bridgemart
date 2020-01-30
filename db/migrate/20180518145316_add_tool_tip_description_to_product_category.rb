class AddToolTipDescriptionToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :tooltip_description, :string
  end
end
