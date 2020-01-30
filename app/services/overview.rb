class Overview
  include Skylight::Helpers
  attr_reader :organizations

  def initialize(organizations)
    @organizations = organizations.order(created_at: :desc)
    raise ActiveRecord::RecordNotFound unless @organizations.any?

    @rough_data = build_rough_data
  end

  def count
    @count ||= @organizations.count
  end

  def enrolled
    @enrolled ||= @organizations.sum { |organization| organization.enrolled? ? 1 : 0 }
  end

  def credit_total
    @credit_total ||= @organizations.sum(&:credit_total)
  end

  def budget_total
    @budget_total ||= Money.new(plan_product_categories.sum(:budget_cents) * members.count, :usd)
  end

  def budget_total_formatted
    budget_total.to_money.format(no_cents: true)
  end

  def budget_json
    consolidate_categories.to_json
  end

  def orders_total
    @orders_total ||= Money.new(line_items.sum(:amount_cents), :usd)
  end

  def usage_percentage
    (usage_total / budget_total * 100).round(2)
  end

  def days_into_period
    @organizations.max_by(&:days_into_period).days_into_period
  end

  def members_without_usage_count
    members.count - members.with_usage.count
  end

  def members_usage_percentage_as_decimal
    members.with_usage.count / members.count * 100.0
  end

  def usages_get_types
    @rough_data.map { |datum| datum[:type] }.uniq
  end

  def usages_build_stacked_area_data
    summed_date_grouped_data = sum_date_grouped_data(usages_get_types, @rough_data.group_by { |h| h[:date] })

    flatten_summed_date_grouped_data(summed_date_grouped_data)
  end

  def usage_total
    Money.new(members.joins(:usages).sum('usages.amount_cents'), :usd)
  end

  def unpaid_orders_total
    @unpaid_orders_total ||= Money.new(unpaid_line_items.sum(:amount_cents), :usd)
  end

  def orders
    @orders ||= Order.joins(:plan).paid.active.where(plans: { organization: @organizations }).order(starts_on: :desc)
  end

  def members
    @members ||= Member.joins(:organization).where(plans: { organization: @organizations })
  end

  private
    def line_items
      @line_items ||= LineItem.where(order: orders)
    end

    def unpaid_line_items
      @unpaid_line_items ||= LineItem.where(order: unpaid_orders)
    end

    def unpaid_orders
      @unpaid_orders ||= Order.joins(:plan).pending.active.where(plans: { organization: @organizations }).order(starts_on: :desc)
    end

    def plan_product_categories
      @plan_product_categories ||= PlanProductCategory.joins(:organization).where(plans: { organization: @organizations })
    end

    def usages
      @usages ||= Usage.joins(:member).where(codes: { member: members })
    end

    def build_rough_data
      usages.map do |usage|
        next unless usage.used_at

        { type: usage.code.product_category.division.name, date: I18n.l(usage.used_at, format: :mmddyyyy), spent: usage.amount.to_f }
      end.compact
    end
    instrument_method :build_rough_data

    def sum_date_grouped_data(types, date_grouped_data)
      date_grouped_data.each_with_object(Hash.new(0)) do |data_group, summed_date_grouped_data|
        current_date = data_group[0]
        date_usage_hashes = data_group[1]

        types.each do |type|
          date_usage_hashes << { type: type, spent: 0 }
        end

        summed_date_grouped_data[current_date] = date_usage_hashes.each_with_object(Hash.new(0)) do |date_usage_hash, summed_date_usage_hash|
          summed_date_usage_hash[date_usage_hash[:type]] += date_usage_hash[:spent]
        end
      end
    end

    def flatten_summed_date_grouped_data(summed_date_grouped_data)
      collection = summed_date_grouped_data.map do |summed_date_group|
        { date: summed_date_group.first }.merge(summed_date_group.second)
      end

      collection.sort_by { |ele| ele[:date] }
    end

    def consolidate_categories
      consolidated = plan_product_categories.group_by(&:name).map do |key, group|
        sum = group.sum(&:budget) * members.count
        {
          name: key,
          amount: sum.to_i,
          amount_formatted: sum.format(no_cents: true)
        }
      end
      consolidated << remaining_balance
      consolidated
    end

    def remaining_balance
      used = budget_total - usage_total
      { name: I18n.t('overview.budget.remaining'), amount: used.to_i, amount_formatted: used.to_money.format(no_cents: true) }
    end
end
