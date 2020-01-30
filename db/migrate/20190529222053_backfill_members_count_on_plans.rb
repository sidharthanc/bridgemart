class BackfillMembersCountOnPlans < ActiveRecord::Migration[5.2]
  def change
    say_with_time "Backport plans.members_count default" do
      Plan.unscoped.update_all(members_count: 0)
    end
    Member.counter_culture_fix_counts
  end
end
