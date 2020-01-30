class CreatePricePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :price_points do |t|
      t.references :product_category, foreign_key: true, null: false
      t.integer :limit
      t.string :verbiage
      t.string :note
      t.integer :limit_type
      t.string :tooltip
      t.string :upgrade_verbiage
      t.string :item_name

      t.timestamps null: false
    end
  end
end
