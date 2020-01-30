class CascadeCodesPlanProductCategoryForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :codes, :plan_product_categories
    add_foreign_key :codes, :plan_product_categories, on_delete: :cascade
  end
end
