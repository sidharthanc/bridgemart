class UpdateOrderStatisticsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    drop_view :organization_statistics
    update_view :order_statistics, version: 2, revert_to_version: 1
    create_view :organization_statistics
  end
end
