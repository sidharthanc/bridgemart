module Views
  class OrganizationStatistics < ApplicationRecord
    self.primary_key = :id

    attribute :total_orders, :integer
    attribute :total_members, :integer
    attribute :total_codes, :integer
    attribute :total_load, :integer
    attribute :total_balance, :integer

    # Not materialized at the moment
    # def self.refresh
    #   Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    # end
  end
end
