class AddAuthenticationTokenToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :authentication_token, :string
  end
end
