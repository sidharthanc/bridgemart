class AddMembersCountToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :members_count, :integer
  end
end
