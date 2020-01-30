class CreateOrganizationStatistics < ActiveRecord::Migration[5.2]
  def change
    drop_view :organization_summaries, materialized: true
    create_view :organization_statistics
  end
end
