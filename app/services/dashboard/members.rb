module Dashboard
  class Members
    include Skylight::Helpers

    def initialize(organization:)
      @organization = organization
    end

    def count
      @count ||= @organization.members_count
    end
    instrument_method :count

    def show?
      @organization.persisted?
    end

    def usage_percentage_as_decimal
      @usage_percentage_as_decimal ||= @organization.members.usage_percentage_as_decimal
    end
    instrument_method :usage_percentage_as_decimal

    def with_usage_count
      @with_usage_count ||= @organization.members.with_usage.size
    end
    instrument_method :with_usage_count

    def without_usage_count
      count - with_usage_count
    end
  end
end
