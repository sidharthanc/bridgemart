class RemoveLocations < ActiveRecord::Migration[5.2]
  def change
    remove_reference :members, :location

    remove_foreign_key :payment_methods, column: :location_id

    drop_table :locations
    drop_table :locations_users
  end
end
