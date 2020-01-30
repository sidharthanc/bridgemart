module Dashboard
  class Orders
    include Skylight::Helpers
    delegate :orders, to: :@organization

    def initialize(organization:)
      @organization = organization
    end

    def total
      Rails.cache.fetch("dashboard/#{@organization.cache_key}/orders/total") do
        # TODO: This is primed for a performance boost.
        orders.where.not(paid_at: nil).sum(&:balance_due)
      end
    end
    instrument_method :total

    def billing_due
      Rails.cache.fetch("dashboard/#{@organization.cache_key}/orders/billing_due") do
        orders.sum(&:balance_due)
      end
    end

    def each(&block)
      # What's calling this, cause this could get bad
      orders.each(&block)
    end
    instrument_method :each
  end
end
