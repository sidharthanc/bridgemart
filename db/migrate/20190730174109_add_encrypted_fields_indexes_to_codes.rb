class AddEncryptedFieldsIndexesToCodes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :codes, :encrypted_card_number, unique: true, algorithm: :concurrently
    add_index :codes, :encrypted_pin, unique: true, algorithm: :concurrently
  end
end
