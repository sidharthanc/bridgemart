class AddLegacyIdentifierToCode < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :legacy_identifier, :bigint, index: true
  end
end
