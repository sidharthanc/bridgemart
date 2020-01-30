class AddErrorMessageToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :error_message, :string
    add_column :orders, :processing, :boolean, default: false
  end
end
