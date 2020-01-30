class AddCardTypeToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :card_type, :string
  end
end
