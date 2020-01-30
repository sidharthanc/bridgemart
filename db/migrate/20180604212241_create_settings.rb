class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
