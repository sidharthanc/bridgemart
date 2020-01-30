class AddIndexesToSlowTables < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :member_imports, :acknowledged, where: "(acknowledged IS FALSE AND problems IS NOT NULL)",  algorithm: :concurrently
  end
end
