class RemovesIndexFromDeletedAtTables < ActiveRecord::Migration[5.2]
  def change
    remove_index :codes, :discarded_at if index_exists?(:codes, :discarded_at)
    remove_index :codes, :member_id if index_exists?(:codes, :member_id)
    remove_index :codes, :plan_product_category_id if index_exists?(:codes, :plan_product_category_id)
    remove_index :credit_purchases, :organization_id
    remove_index :credit_purchases, :payment_method_id
    remove_index :credits, :organization_id
    remove_index :credits, %i[source_id source_type]
    remove_index :credits, %i[source_type source_id]
    remove_index :line_items, :order_id
    remove_index :line_items, %i[source_id source_type]
    remove_index :line_items, %i[source_type source_id]
    remove_index :members, :order_id
    remove_index :orders, :discarded_at
    remove_index :orders, :payment_method_id
    remove_index :orders, :plan_id
    remove_index :organization_users, :organization_id
    remove_index :organization_users, :user_id
    remove_index :organizations, :created_at
    remove_index :organizations, :discarded_at
    remove_index :organizations, :primary_user_id
    remove_index :payment_methods, :customer_vault_id
    remove_index :payment_methods, :location_id
    remove_index :payment_methods, :organization_id
    remove_index :plans, :organization_id
    remove_index :product_categories, :division_id
    remove_index :redemption_instructions, :organization_id
    remove_index :redemption_instructions, :product_category_id
    remove_index :signatures, :commercial_agreement_id
    remove_index :signatures, :organization_id
    remove_index :special_offers, :product_category_id
    remove_index :usages, :code_id
    remove_index :users, :discarded_at
  end
end
