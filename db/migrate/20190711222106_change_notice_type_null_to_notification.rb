class ChangeNoticeTypeNullToNotification < ActiveRecord::Migration[5.2]
  def change
    change_column_null :notifications, :notice_type, true
  end
end
