class FixDefaultCodeFieldsValue < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:codes, :fields, {})
  end
end
