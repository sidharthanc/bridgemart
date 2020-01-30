class RemovePlanFromMember < ActiveRecord::Migration[5.2]
  def change
    remove_reference :members, :plan, foreign_key: true
  end
end
