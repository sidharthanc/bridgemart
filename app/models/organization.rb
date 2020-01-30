class Organization < ApplicationRecord
  acts_as_paranoid # Implements Soft Delete for Organizations

  include Creditable
  include HasAddress
  include Memoizer

  audited

  has_many :organization_users, dependent: :destroy
  has_many :users, through: :organization_users
  has_many :plans, dependent: :destroy
  has_many :signatures, dependent: :destroy
  has_many :commercial_agreements, through: :signatures
  has_many :orders, through: :plans
  has_many :members, through: :orders
  has_many :usages, through: :members
  has_many :plan_product_categories, through: :plans
  has_many :product_categories, through: :plan_product_categories
  has_many :payment_methods, dependent: :destroy
  has_many :member_imports, through: :orders
  has_many :credit_purchases, dependent: :destroy
  has_many :redemption_instructions
  has_many :credits, dependent: :destroy
  has_one_attached :logo
  has_one :statistics, class_name: 'Views::OrganizationStatistics'

  belongs_to :primary_user, class_name: 'User'

  validates :name, :industry, presence: true
  monetize :credit_total_cached_cents, allow_nil: true
  monetize :usage_total_cached_cents, allow_nil: true

  def address
    super || payment_methods.includes(:address).presence&.first&.address
  end

  def active_plan
    orders.active.last.plan
  end

  def account_status
    Rails.cache.fetch("organizations/#{cache_key}/account_status", expires_in: 1.day) do
      orders.failed.exists? ? :billing_issue : :good
    end
  end

  # defunct, remove when confirmed
  def update_account_status_cached
    update(account_status_cached: calculate_account_status)
    account_status_cached
  end

  def status
    orders.any? ? 'green' : 'red'
  end

  # These two methods are _very_ expensive. We should refactor the underlying issue, which is not having the
  # order totals be cached, at least when generated.
  def ytd_load
    Rails.cache.fetch("organizations/#{cache_key}/calculations/ytd_load") do
      ytd_load_cents = 
      orders.paid
              .where(starts_on: Date.current.beginning_of_year...Date.current)
              .joins(:codes)
              .group('orders.id')
              .pluck(Arel.sql("sum(codes.limit_cents) as order_sum")).sum

      Money.new(ytd_load_cents || 0, "USD")
    end
  end
  instrument_method :ytd_load

  def lifetime_load
    Rails.cache.fetch("organizations/#{cache_key}/calculations/lifetime_load") do
      lifetime_load_cents = 
        orders.paid
              .joins(:codes)
              .group('orders.id')
              .pluck(Arel.sql("sum(codes.limit_cents) as order_sum")).sum

      Money.new(lifetime_load_cents || 0, "USD")
    end
  end
  instrument_method :lifetime_load

  def usage_total
    usage_total_cached || sum_monetized(usages, :amount)
  end
  memoize :usage_total

  def usage_total_ytd
    Rails.cache.fetch("organizations/#{cache_key}/calculations/usage_total_ytd", expires_in: 1.day) do
      usage_total_ytd =
        usages.where("usages.created_at >= ?", Date.new(Date.current.year))
              .sum(:amount_cents)
      Money.new(usage_total_ytd)
    end
  end
  instrument_method :usage_total_ytd

  def usage_percentage_ytd
    return 0 if usage_total_ytd.zero? || ytd_load.zero?

    ((usage_total_ytd.to_f / ytd_load.to_f) * 100.0).round
  end
  instrument_method :usage_percentage_ytd

  def days_into_period
    order = orders.where(starts_on: Date.current.beginning_of_year..Date.current).order(starts_on: :asc).first
    order.present? ? (Date.current - order.starts_on).to_i : 0
  end
  instrument_method :days_into_period

  def has_signed(agreement)
    commercial_agreements.exists? agreement.id
  end

  def active_agreement
    CommercialAgreement.where(organization: [id, nil]).order('organization_id DESC NULLS LAST, created_at DESC').first
  end

  def member_import_errors?
    member_imports.unacknowledged.where.not(problems: nil).where(["LENGTH(problems::text) > 2"]).any?
  end

  def enrolled?
    members.any?
  end

  def product_categories_for_redemption_instructions
    product_categories.distinct.where(redemption_instructions_editable: true)
  end

  def require_address?
    false
  end

  def credit_amount_available?(amount)
    sum_monetized(credits, :amount) >= amount.to_money
  end

  def update_credit_cache
    self.credit_total_cached = sum_monetized(credits, :amount)
    update(credit_total_cached: credit_total_cached)
  end

  def update_usage_total_cache
    self.usage_total_cached = sum_monetized(usages, :amount)
    update(usage_total_cached: usage_total_cached)
  end

  concerning :AuthenticationToken do
    included do
      before_save :ensure_authentication_token
    end

    def ensure_authentication_token
      self.authentication_token = generate_authentication_token if authentication_token.blank?
    end

    private
      def generate_authentication_token
        loop do
          token = Devise.friendly_token(72)
          break token unless Organization.where(authentication_token: token).exists?
        end
      end
  end
end
