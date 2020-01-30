class ChangeLegacyIdentifierToStringInOrganization < ActiveRecord::Migration[5.2]
  def up
    change_column :organizations, :legacy_identifier, :string
    change_column :orders, :legacy_identifier, :string
  end

  def down
    change_column :organizations, :legacy_identifier, :integer, using: 'legacy_identifier::integer'
    change_column :orders, :legacy_identifier, :integer, using: 'legacy_identifier::integer'
  end
end
