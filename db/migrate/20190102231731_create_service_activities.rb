class CreateServiceActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :service_activities do |t|
      t.string :service
      t.string :action
      t.string :message
      t.datetime :successful_at
      t.datetime :failure_at
      t.jsonb :exception, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
