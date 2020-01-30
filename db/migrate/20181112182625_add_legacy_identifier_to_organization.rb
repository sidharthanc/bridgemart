class AddLegacyIdentifierToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :legacy_identifier, :bigint, index: true

    create_table :import_errors do |t|
      t.string :full_filepath
      t.string :error_message
      t.bigint :csv_row_number
      t.jsonb :csv_record

      t.timestamps null: false
    end
  end
end
