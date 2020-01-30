class BackfillMemberCountToOrganization < ActiveRecord::Migration[5.2]
  def up
    say_with_time "Backport organization.members_count default" do
      Organization.unscoped.update_all(members_count: 0)
    end
    Member.counter_culture_fix_counts
  end
end
