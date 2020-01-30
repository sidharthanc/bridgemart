class IndexCredits < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :credits, %i[source_id source_type], algorithm: :concurrently
  end
end
