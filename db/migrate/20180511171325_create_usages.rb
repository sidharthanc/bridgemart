class CreateUsages < ActiveRecord::Migration[5.2]
  def change
    create_table :usages do |t|
      t.belongs_to :code, foreign_key: true
      t.integer :amount_cents

      t.timestamps
    end
  end
end
