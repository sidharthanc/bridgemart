class SetUseEnhancedDashboardDefaultOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :use_enhanced_dashboard, from: nil, to: false
  end
end
