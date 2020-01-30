class AddMemberCountDefaultToOrganization < ActiveRecord::Migration[5.2]
  def change
    change_column_default :organizations, :members_count, from: nil, to: 0
  end
end
