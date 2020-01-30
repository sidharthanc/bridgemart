module Dashboard
  class Organization
    attr_reader :organization

    delegate :permission_target, to: :organization

    def initialize(organization)
      @organization = organization
    end

    def budget
      @budget ||= Dashboard::Budget.new categories: Dashboard::Category.wrap_all(@organization.plan_product_categories), usage_total: @organization.usage_total
    end

    def orders
      @orders ||= Dashboard::Orders.new organization: @organization
    end

    def members
      @members ||= Dashboard::Members.new organization: @organization
    end

    def usages
      @usages ||= Dashboard::Usages.new organization: @organization
    end

    def show?
      @show ||= @organization.present? && budget.show? && products.show? && members.show?
    end

    def future?
      @future ||= @organization.orders.last.future? # TODO: ?
    end
  end
end
