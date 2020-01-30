module Views
  class OrderStatistics < ApplicationRecord
    self.primary_key = :id

    attribute :starts_on, :date
    attribute :ends_on, :date
    attribute :order_total_limit, :integer
    attribute :order_total_balance, :integer

    # Not materialized at the moment
    # def self.refresh
    #   Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    # end
  end
end
