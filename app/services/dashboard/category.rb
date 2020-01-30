module Dashboard
  class Category < DelegateClass(PlanProductCategory)
    include Skylight::Helpers

    def reload
      plan.reload
    end

    def amount
      @amount ||= budget * plan.members_count
    end
    instrument_method :amount

    def amount_formatted
      amount.format(no_cents: true)
    end

    def self.wrap_all(models)
      models.map { |category_model| new category_model }
    end
  end
end
