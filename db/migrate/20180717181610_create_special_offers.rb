class CreateSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :special_offers do |t|
      t.string :name
      t.text :description
      t.references :product_category, foreign_key: true

      t.timestamps
    end
  end
end
