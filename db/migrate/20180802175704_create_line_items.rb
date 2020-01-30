class CreateLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :line_items do |t|
      t.references :order, foreign_key: true, null: false
      t.references :source, polymorphic: true
      t.string :description
      t.integer :charge_type, default: 0
      t.monetize :amount
      t.integer :quantity

      t.timestamps
    end
  end
end
