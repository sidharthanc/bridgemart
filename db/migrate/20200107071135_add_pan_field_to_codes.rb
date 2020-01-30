class AddPanFieldToCodes < ActiveRecord::Migration[5.2]
  def change
  	add_column :codes, :pan, :string
  end
end
