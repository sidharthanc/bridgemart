class AddsIndexToDeletedAtTables < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :codes, :discarded_at, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :codes, :member_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :codes, :plan_product_category_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :credit_purchases, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :credit_purchases, :payment_method_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :credits, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :credits, %i[source_id source_type], where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :credits, %i[source_type source_id], where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :line_items, :order_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :line_items, %i[source_id source_type], where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :line_items, %i[source_type source_id], where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :members, :order_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :orders, :discarded_at, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :orders, :payment_method_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :orders, :plan_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organization_users, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organization_users, :user_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organizations, :created_at, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organizations, :discarded_at, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organizations, :primary_user_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :payment_methods, :customer_vault_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :payment_methods, :location_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :payment_methods, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :plans, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :product_categories, :division_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :redemption_instructions, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :redemption_instructions, :product_category_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :signatures, :commercial_agreement_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :signatures, :organization_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :special_offers, :product_category_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :usages, :code_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :users, :discarded_at, where: "deleted_at IS NULL", algorithm: :concurrently
  end
end
