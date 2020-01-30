class ManyToManyUserLocations < ActiveRecord::Migration[5.2]
  def up
    create_join_table :locations, :users do |t|
      t.index :location_id
      t.index :user_id
    end

    User.find_each do |user|
      user.locations << Location.find(user.location_id) if user.location_id
    end

    remove_column :users, :location_id
  end

  def down
    add_reference :users, :location, index: true

    User.find_each do |user|
      user.location_id = user.locations.first.id if user.locations.any?
    end

    drop_join_table :locations, :users
  end
end
