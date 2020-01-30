class AddDiscardSupport < ActiveRecord::Migration[5.2]
  def change
    add_column :billing_contacts, :discarded_at, :datetime
    add_index :billing_contacts, :discarded_at

    add_column :codes, :discarded_at, :datetime
    add_index :codes, :discarded_at

    add_column :divisions, :discarded_at, :datetime
    add_index :divisions, :discarded_at

    add_column :orders, :discarded_at, :datetime
    add_index :orders, :discarded_at

    add_column :organizations, :discarded_at, :datetime
    add_index :organizations, :discarded_at

    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at
  end
end
