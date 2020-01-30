class AddEncryptedFieldsToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :encrypted_pin, :string
    add_column :codes, :encrypted_pin_iv, :string
    add_column :codes, :encrypted_card_number, :string
    add_column :codes, :encrypted_card_number_iv, :string
  end
end
