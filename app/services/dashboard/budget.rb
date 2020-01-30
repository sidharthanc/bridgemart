module Dashboard
  class Budget
    include Skylight::Helpers

    def initialize(categories:, usage_total: nil)
      @categories = categories
      @usage_total = usage_total
    end

    def reload
      # Perf: What is calling this, and why?
      @categories.map(&:reload)
    end

    def total
      @total ||= @categories.sum(&:amount).to_money
    end
    instrument_method :total

    def total_formatted
      total.format(no_cents: true)
    end

    def show?
      total.positive?
    end

    def to_json(*_args)
      @to_json ||= consolidate_categories.to_json
    end

    def consolidate_categories
      # Do this in the db (group/sum)
      # Will need refactor quite a bit
      consolidated = @categories.group_by(&:name).map do |key, group|
        sum = group.sum(&:amount)
        {
          name: key,
          amount: sum.to_i,
          amount_formatted: sum.format(no_cents: true)
        }
      end
      consolidated
    end
    instrument_method :consolidate_categories

    private
      def remaining_balance
        used = total - @usage_total
        { name: I18n.t('pages.dashboard.budget.remaining'), amount: used.to_i, amount_formatted: used.to_money.format(no_cents: true) }
      end
  end
end
