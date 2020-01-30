class IndexPermissionGroupOwnerships < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :permission_group_ownerships, %i[owner_id owner_id], name: :index_pgo_on_permission_group_id_and_user_id, algorithm: :concurrently
  end
end
