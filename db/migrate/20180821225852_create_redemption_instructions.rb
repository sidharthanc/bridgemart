class CreateRedemptionInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :redemption_instructions do |t|
      t.text :description
      t.string :title
      t.boolean :active
      t.references :organization, index: true
      t.references :product_category, index: true
    end
  end
end
