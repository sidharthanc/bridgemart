class BackportUseEnhancedDashboardDefaultOnUsers < ActiveRecord::Migration[5.2]
  def up
    say_with_time "Backport users.use_enhanced_dashboard default" do
      User.unscoped.select(:id).find_in_batches.with_index do |batch, index|
        say("Processing batch #{index}\r", false)
        User.unscoped.where(id: batch).update_all(use_enhanced_dashboard: false)
      end
    end
  end
end
