class AddSingleUseOnlyToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :single_use_only, :boolean, default: false
  end
end
