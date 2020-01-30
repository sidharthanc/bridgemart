class AddCreatedAtIndexToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_index :organizations, :created_at
  end
end
