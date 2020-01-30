class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.references :organization
      t.string :name
      t.string :email
      t.string :contact_name

      t.timestamps
    end

    add_reference :users, :location, index: true
    add_reference :members, :location, index: true
  end
end
