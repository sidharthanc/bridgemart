class AddUseEnhancedDashboardToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :use_enhanced_dashboard, :boolean
  end
end
