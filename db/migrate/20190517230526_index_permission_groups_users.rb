class IndexPermissionGroupsUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :permission_groups_users, %i[permission_group_id user_id], name: :index_pgu_on_permission_group_id_and_user_id, algorithm: :concurrently
  end
end
