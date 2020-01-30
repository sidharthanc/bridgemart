class RemovePlanIdFromMemberImports < ActiveRecord::Migration[5.2]
  def change
    remove_column :member_imports, :plan_id
  end
end
