class AddStartsOnEndsOnIndexToOrtders < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :orders, [:id, :starts_on, :ends_on], algorithm: :concurrently
  end
end
