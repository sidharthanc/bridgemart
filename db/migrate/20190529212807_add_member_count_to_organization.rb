class AddMemberCountToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :members_count, :integer
  end
end
