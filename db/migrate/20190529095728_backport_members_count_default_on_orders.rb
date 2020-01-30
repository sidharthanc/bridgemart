class BackportMembersCountDefaultOnOrders < ActiveRecord::Migration[5.2]
  def up
    say_with_time "Backport orders.members_count default" do
      Order.unscoped.select(:id).find_in_batches.with_index do |batch, index|
        say("Processing batch #{index}\r", 0)
        Order.unscoped.where(id: batch).update_all(members_count: 0)
      end
    end
    Member.counter_culture_fix_counts
  end
end
