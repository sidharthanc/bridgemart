class AddBackgroundColorToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :background_color, :string, default: 'lightgreen'
  end
end
