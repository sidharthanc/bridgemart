class AddTemplateIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :template_id, :string
  end
end
