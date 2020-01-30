class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :plan, foreign_key: true
      t.datetime :paid_at
      t.timestamps
    end
  end
end
