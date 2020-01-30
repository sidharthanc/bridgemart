class CreatePlanProductCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_product_categories do |t|
      t.references :plan, foreign_key: true, null: false
      t.references :product_category, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
