class AddVirtalCardProviderToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :virtual_card_provider, :string
  end
end
