class AdjustPinIndexOnCodes < ActiveRecord::Migration[5.2]
  def change
    remove_index :codes, :encrypted_pin
  end
end
