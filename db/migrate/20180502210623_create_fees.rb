class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.string :description
      t.monetize :rate

      t.timestamps
    end
  end
end
