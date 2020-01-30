class AddPlanToMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :members, :plan, foreign_key: true
  end
end
