class AddDeleteAtToDependantTables < ActiveRecord::Migration[5.2]
  # Adds deleted_at to soft-deletable models
  def change
    add_column :organization_users, :deleted_at, :datetime
    add_column :plans, :deleted_at, :datetime
    add_column :signatures, :deleted_at, :datetime
    add_column :credits, :deleted_at, :datetime
    add_column :payment_methods, :deleted_at, :datetime
    add_column :credit_purchases, :deleted_at, :datetime
    add_column :redemption_instructions, :deleted_at, :datetime
    add_column :plan_product_categories, :deleted_at, :datetime
    add_column :orders, :deleted_at, :datetime
    add_column :members, :deleted_at, :datetime
    add_column :codes, :deleted_at, :datetime
    add_column :line_items, :deleted_at, :datetime
    add_column :product_categories, :deleted_at, :datetime
    add_column :special_offers, :deleted_at, :datetime
    add_column :usages, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :organizations, :deleted_at, :datetime
  end
end
