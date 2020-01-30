class IndexActiveAdminComments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :active_admin_comments, %i[author_id author_type], algorithm: :concurrently
    add_index :active_admin_comments, %i[resource_id resource_type], algorithm: :concurrently
  end
end
