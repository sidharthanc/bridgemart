class CreateCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :codes do |t|
      t.belongs_to :member, foreign_key: true
      t.integer :balance_cents, default: 0
      t.integer :limit_cents
      t.string :status
      t.string :external_id

      t.timestamps
    end
  end
end
