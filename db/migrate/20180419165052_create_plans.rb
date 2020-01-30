class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.date :start_date
      t.date :end_time
      t.references :organization, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
