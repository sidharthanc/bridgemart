class AddUniqueIndexToEmailDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users, %i[email deleted_at], unique: true, algorithm: :concurrently
  end
end
