class CreateOrganizationSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :organization_summaries, materialized: true
    safety_assured { add_index :organization_summaries, :id, unique: true }
  end
end
