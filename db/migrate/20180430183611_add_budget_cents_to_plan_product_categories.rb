class AddBudgetCentsToPlanProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_monetize :plan_product_categories, :budget
  end
end
