class Order < ApplicationRecord
  acts_as_paranoid

  CSV_HEADERS = %w[ id plan_id paid_at created_at updated_at starts_on ends_on po_number payment_method_id error_message
                    started_at amount paid legacy_identifier ].freeze

  after_create :copy_redemption_instructions

  audited

  attribute :terms_and_conditions

  belongs_to :plan
  belongs_to :payment_method, optional: true
  has_one :address, through: :payment_method
  has_one :billing_contact, through: :payment_method
  has_one :organization, through: :plan
  has_one_attached :pdf
  has_many :member_imports, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :codes, through: :members
  has_many :plan_product_categories, through: :plan
  has_many :product_categories, through: :plan_product_categories
  has_many :line_items, dependent: :destroy
  has_many :redemption_instructions, through: :product_categories
  has_and_belongs_to_many :special_offers
  has_many :divisions, through: :product_categories

  before_destroy { throw(:abort) if fulfilled? }

  # Views
  has_one :statistics, class_name: 'Views::OrderStatistics'

  accepts_nested_attributes_for :plan_product_categories
  validates_associated :plan_product_categories, on: :update

  scope :paid, -> { where.not(paid_at: nil) }
  scope :pending, -> { where(paid_at: nil, processed_at: nil) }
  scope :failed, -> { where(paid_at: nil).where.not(processed_at: nil) }
  scope :cancelled, -> { where(is_cancelled: true) }
  scope :chronological, -> { order(:created_at) }
  scope :starts_up_to_today, -> { where('starts_on <= ?', Date.current.at_midnight) }
  scope :unstarted, -> { where(started_at: nil) }
  scope :active, -> { where(arel_table[:starts_on].lteq(Date.current)).where(arel_table[:ends_on].gteq(Date.current)) }

  scope :has_members, -> { where(id: Member.select(:order_id)) }

  delegate :primary_user, to: :organization
  delegate :email, to: :primary_user
  monetize :amount_cents, :applied_credit_cents
  monetize :total_cached_cents, allow_nil: true
  monetize :total_fees_cached_cents, allow_nil: true
  monetize :total_charges_cached_cents, allow_nil: true

  ransack_alias :order, :po_number_or_id

  def self.ransackable_scopes(_auth_object = nil)
    [:status_in]
  end

  def fulfilled?
    codes.where.not(encrypted_card_number: nil).any?
  end

  # TODO: we will have to decide what to use that will determine an order as fulfilled
  def self.status_in(status)
    case status.parameterize.underscore.to_sym
    when :paid
      paid
    when :pending_payment
      pending
    when :cancelled
      cancelled
    else
      all
    end
  end

  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '9999999999')")
  end

  ransacker :members, formatter: proc { |selected_order_id|
                                   results = Order.where(id: selected_order_id).map(&:id)
                                   results.present? ? results : nil
                                 }, splat_params: true do |parent|
    parent.table[:id]
  end

  ransacker :plan_product_categories, formatter: proc { |selected_product_category_id|
                                                   product_category = ProductCategory.where(id: selected_product_category_id).first
                                                   results = product_category.present? ? Order.where(plan_id: product_category.plans.pluck(:id)).map(&:id) : nil
                                                   results.present? ? results : nil
                                                 }, splat_params: true do |parent|
    parent.table[:id]
  end

  concerning :PlanRange do
    included do
      before_validation(on: :create) do
        self.ends_on = starts_on + 1.year unless attribute_present?("ends_on")
      end

      validates :starts_on, :ends_on, presence: true
      validates :starts_on, inclusion: { in: (Date.current..(Date.current + 1.month)) }, on: :create
      validates :ends_on, inclusion: { in: ->(record) { (record.starts_on.next)..(record.starts_on + 1.year) } }
    end

    def starts_on=(date)
      super if date.is_a?(Date)

      super(Chronic.parse(date.to_s))
    end

    def ends_on=(date)
      super if date.is_a?(Date)

      super(Chronic.parse(date.to_s))
    end

    def future?
      starts_on&.future?
    end
  end

  def legacy?
    legacy_identifier.present?
  end

  def update_code_delivery
    codes.update_all(delivered: true)
  end

  def has_members?
    members_count.positive?
  end

  def order_identifier
    legacy_identifier.present? ? legacy_identifier : id
  end

  def charges
    # This may be too high level to cache well, will have to keep an eye on it
    Rails.cache.fetch("orders/#{cache_key}/charges") do
      if legacy?
        amount = sum_monetized(line_items.charges, :amount)
        count = line_items.charges.sum(:quantity)
        count += 1 if count.zero?
        charge = OpenStruct.new(description: product_categories.first&.name || 'Legacy Product Charge', rate: amount / count)
        [Charge.new(charge, count, :charge)]
      else
        plan_product_categories.includes(:product_category, :plan).map do |plan_product_category|
          Charge.new plan_product_category.product_fee, members.size, :charge
        end
      end
    end
  end

  def fees
    # This may be too high level to cache well, will have to keep an eye on it
    Rails.cache.fetch("orders/#{cache_key}/fees") do
      if legacy?
        amount = sum_monetized(line_items.fees, :amount)
        count = line_items.fees.sum(:quantity)
        count += 1 if count.zero?
        fee = OpenStruct.new(description: product_categories.first&.name || 'Legacy Product Fee', rate: amount / count)
        [Charge.new(fee, count, :fee)]
      else
        plan_product_categories.map do |plan_product_category|
          Charge.new plan_product_category.bridge_fee, members.size, :fee
        end
      end
    end
  end

  def credits
    line_items.applied_credits
  end

  def customer_vault_id
    payment_method&.customer_vault_id
  end

  def total
    Rails.cache.fetch("orders/#{cache_key}/calculated/total") do
      total_charges + total_fees
    end
  end

  def total_with_credits
    total - total_credits
  end

  def total_charges
    Rails.cache.fetch("orders/#{cache_key}/calculated/total_charges") do
      charges.sum(&:price).to_money
    end
  end

  def total_fees
    Rails.cache.fetch("orders/#{cache_key}/calculated/total_fees") do
      fees.sum(&:price).to_money
    end
  end

  def total_credits
    sum_monetized(credits, :amount)
  end

  def formatted_total
    total.format
  end

  def has_no_due?
    paid_at? || is_cancelled?
  end

  def balance_due
    has_no_due? ? 0.to_money : total_with_credits
  end

  def deduct_credits(amount)
    # TODO: Make idempotent
    return false if amount.zero? || !organization.credit_amount_available?(amount)

    line_items.create!(
      amount: adjusted_amount(amount),
      source_id: id,
      source_type: Order,
      description: (I18n.t 'orders.credits_from', source_name: organization.name),
      charge_type: :credit
    )

    credits.each do |line_item|
      # This adjusts the credits down if they 'over credit' an order
      line_item.source.organization.credits.create(amount: -line_item.amount, source: line_item.source) if line_item.source && line_item.source.organization.credit_total >= line_item.amount
    end
  end

  def create_line_items
    (charges + fees).each do |item|
      line_items.create(amount: (item.rate * members_count), description: item.description, charge_type: item.kind, quantity: members_count)
    end
  end

  def status
    Rails.cache.fetch("orders/#{cache_key}/calculated/status") do
      if paid?
        :paid
      elsif is_cancelled
        :cancelled
      elsif error_message
        :failed
      elsif has_members?
        :pending
      else
        :invalid
      end
    end
  end

  def require_address?
    false
  end

  def paid?
    paid_at?
  end

  def unpaid?
    !paid?
  end

  def cancelled?
    is_cancelled
  end

  def started!
    update started_at: Time.current
  end

  def cancel
    update is_cancelled: true
  end

  def started?
    started_at?
  end

  def member_import_errors?
    member_imports.unacknowledged.map(&:errors?).any?
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers

      all.each do |order|
        csv << CSV_HEADERS.map { |attr| order.send(attr) }
      end
    end
  end

  def self.column_headers
    CSV_HEADERS.map do |col|
      I18n.t("orders.index.columns.#{col}")
    end
  end

  def amount
    sum_monetized(line_items, :amount)
  end

  def program_types
    divisions.distinct.pluck(:name)
  end

  def processed?
    processed_at.present?
  end

  private

    def adjusted_amount(amount)
      return amount if amount.to_money <= total_with_credits

      total_with_credits
    end

    def copy_redemption_instructions
      product_categories.each do |product_category|
        next if product_category.default_redemption_instructions.blank?

        created = create_redemption_instruction(product_category)
        unless active_redemption_instruction_exists?
          created.active = true
          created.save!
        end
      end
    end

    def create_redemption_instruction(product_category)
      RedemptionInstruction.find_or_create_by(
        description: product_category.default_redemption_instructions,
        title: product_category.name,
        product_category_id: product_category.id,
        organization_id: organization.id
      )
    end

    def active_redemption_instruction_exists?
      redemption_instructions.where(active: true).exists?
    end
end
