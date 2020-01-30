class AddLegacyIdentifierIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :legacy_identifier, unique: true
    add_index :organizations, :legacy_identifier, unique: true
    add_index :codes, :legacy_identifier, unique: true
  end
end
