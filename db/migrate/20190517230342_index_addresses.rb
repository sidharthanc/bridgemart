class IndexAddresses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :addresses, %i[addressable_id addressable_type], algorithm: :concurrently
  end
end
