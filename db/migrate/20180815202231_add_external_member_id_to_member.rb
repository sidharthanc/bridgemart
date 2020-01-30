class AddExternalMemberIdToMember < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :external_member_id, :string
  end
end
