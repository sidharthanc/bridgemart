class RemoveDateOfBirthFromMembers < ActiveRecord::Migration[5.2]
  def change
    remove_column :members, :dob, :date
  end
end
