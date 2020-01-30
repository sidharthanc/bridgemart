class AddTokenUrlsToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :barcode_url, :string
    add_column :codes, :card_image_url, :string
  end
end
