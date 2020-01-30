class AddAuthenticationTokenToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :authentication_token, :string
  end
end
