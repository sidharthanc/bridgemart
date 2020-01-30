class IndexLineItems < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :line_items, %i[source_id source_type], algorithm: :concurrently
  end
end
