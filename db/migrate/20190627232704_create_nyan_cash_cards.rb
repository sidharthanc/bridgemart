class CreateNyanCashCards < ActiveRecord::Migration[5.2]
  def change
    create_table :nyan_cash_cards do |t|
      t.string :card_number
      t.string :pin
      t.datetime :locked_at
      t.datetime :expires_at
      t.datetime :closed_at
      t.integer :initial_balance
      t.integer :current_balance

      t.timestamps
    end
  end
end
