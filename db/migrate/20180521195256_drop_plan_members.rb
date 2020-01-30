class DropPlanMembers < ActiveRecord::Migration[5.2]
  def change
    drop_table :plan_members if table_exists? :plan_members
  end
end
