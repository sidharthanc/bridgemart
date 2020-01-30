class IndexAudits < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :audits, %i[associated_id associated_type], algorithm: :concurrently
    add_index :audits, %i[auditable_id auditable_type], algorithm: :concurrently
  end
end
