class AddTitleToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :title, :string
    remove_column :billing_contacts, :role
  end
end
