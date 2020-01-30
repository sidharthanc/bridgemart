class AddUuidToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :uuid, :uuid
  end
end
