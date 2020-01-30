class AddCurrencyToUsage < ActiveRecord::Migration[5.2]
  def change
    add_column :usages, :amount_currency, :string, default: 'USD', null: false
  end
end
