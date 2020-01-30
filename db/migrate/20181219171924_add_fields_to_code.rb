class AddFieldsToCode < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :fields, :jsonb, default: '{}'
  end
end
