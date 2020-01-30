class AddPlanProductCategoryIdToCodes < ActiveRecord::Migration[5.2]
  def change
    add_reference :codes, :plan_product_category, foreign_key: true
  end
end
