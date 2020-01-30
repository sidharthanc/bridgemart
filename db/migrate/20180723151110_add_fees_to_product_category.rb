class AddFeesToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :fee_type, :integer, default: 0

    add_column :product_categories, :percentage_fee, :float
    add_monetize :product_categories, :flat_fee
  end
end
