class AddIndexesForDeletedAtToDependentTables < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :organization_users, :deleted_at, algorithm: :concurrently
    add_index :plans, :deleted_at, algorithm: :concurrently
    add_index :signatures, :deleted_at, algorithm: :concurrently
    add_index :credits, :deleted_at, algorithm: :concurrently
    add_index :payment_methods, :deleted_at, algorithm: :concurrently
    add_index :credit_purchases, :deleted_at, algorithm: :concurrently
    add_index :redemption_instructions, :deleted_at, algorithm: :concurrently
    add_index :plan_product_categories, :deleted_at, algorithm: :concurrently
    add_index :orders, :deleted_at, algorithm: :concurrently
    add_index :members, :deleted_at, algorithm: :concurrently
    add_index :codes, :deleted_at, algorithm: :concurrently
    add_index :line_items, :deleted_at, algorithm: :concurrently
    add_index :product_categories, :deleted_at, algorithm: :concurrently
    add_index :special_offers, :deleted_at, algorithm: :concurrently
    add_index :usages, :deleted_at, algorithm: :concurrently
    add_index :users, :deleted_at, algorithm: :concurrently
    add_index :organizations, :deleted_at, algorithm: :concurrently
  end
end
