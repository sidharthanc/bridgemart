class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :sent_to, null: false, index: true
      t.string :notice_type, null: false
      t.timestamps
    end
  end
end
