class AddToPlanProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_product_categories, :usage_type, :string, default: :multi_use
  end
end
