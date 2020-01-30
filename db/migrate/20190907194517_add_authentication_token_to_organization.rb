class AddAuthenticationTokenToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :authentication_token, :string
  end
end
