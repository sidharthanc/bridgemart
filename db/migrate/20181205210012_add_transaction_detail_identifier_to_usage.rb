class AddTransactionDetailIdentifierToUsage < ActiveRecord::Migration[5.2]
  def change
    add_column :usages, :transaction_detail_identifier, :bigint, index: true
  end
end
