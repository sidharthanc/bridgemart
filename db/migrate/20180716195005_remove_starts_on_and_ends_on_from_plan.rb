class RemoveStartsOnAndEndsOnFromPlan < ActiveRecord::Migration[5.2]
  def change
    remove_column :plans, :starts_on
    remove_column :plans, :ends_on
  end
end
