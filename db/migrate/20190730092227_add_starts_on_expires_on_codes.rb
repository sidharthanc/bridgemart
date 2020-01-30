class AddStartsOnExpiresOnCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :starts_on, :date
    add_column :codes, :expires_on, :date
  end
end
