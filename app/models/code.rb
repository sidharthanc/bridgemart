require 'closed_loop'
require 'first_data/encryption'

class Code < ApplicationRecord
  acts_as_paranoid

  include AASM
  include Deactivatable
  include TokenAuthenticatable
  include DeliverCodes
  include Codes::Barcode
  include Wisper::Publisher

  audited

  LOCK_REASONS = %i[damaged lost office_error expired stolen unclaimed misc].freeze
  UNLOCK_REASONS = %i[found replaced renewed misc].freeze

  belongs_to :member, touch: true
  belongs_to :plan_product_category

  has_one :plan, through: :member
  has_one :order, through: :member
  has_one :organization, through: :order
  has_one :product_category, through: :plan_product_category
  has_one_attached :pdf

  has_many :usages, dependent: :destroy
  has_many :price_points, through: :product_category
  has_many :credits, as: :source

  validates :legacy_identifier, uniqueness: true, unless: -> { legacy_identifier.blank? }

  scope :recent, -> { order('created_at DESC').limit(5) }
  scope :undeactivated, -> { where(deactivated_at: nil) }
  scope :active, -> { where(deactivated_at: nil).where.not(external_id: nil) }
  scope :at_or_past_expiration, -> { undeactivated.joins(:order).where('orders.ends_on < ?', Time.current) }
  scope :unexpired, -> { undeactivated.joins(:order).where('orders.ends_on >= ?', Time.current) }
  scope :with_card_type, ->(card_type) { joins(:product_category).where(product_categories: { card_type: card_type }) }
  scope :code_status, lambda { |status|
    if status.present? && status == "used"
      where('limit_cents != balance_cents')
    elsif status.present? && status == "unused"
      where('limit_cents = balance_cents')
    end
  }
  monetize :balance_cents
  monetize :limit_cents
  monetize :unloaded_amount_cents

  attr_encrypted :pin, key: Rails.application.credentials.key
  attr_encrypted :card_number, key: Rails.application.credentials.key

  delegate :usage_type, :single_use?, :multi_use?, to: :plan_product_category
  delegate :ends_on, to: :order
  delegate :description, :product_description, to: :product_category

  aasm column: :status do
    state :generated, initial: true
    state :activating
    state :activated
    state :registered
    state :locking
    state :locked
    state :closed
    state :unlocking
    state :partially_used
    state :used
    state :deactivated
  end

  enum virtual_card_provider: { first_data: 'first_data', eml: 'eml' }

  after_commit :activate, on: :create, if: -> { uses_provider? && card_provider.present? }
  ransack_alias :code, :order_id_or_balance_cents_or_id_or_created_at_date_equals_or_product_category_name_eq
  # TODO: If this does not scale, replace the ransacker with a table column containing the stringized id value

  ransacker :balance_cents do
    Arel.sql("to_char(\"codes\".\"balance_cents\", '9999999999')")
  end

  ransacker :id do
    Arel.sql("to_char(\"codes\".\"id\", '9999999999')")
  end

  ransacker :balance, formatter: proc { |v| v.to_i * 100 } do |parent|
    parent.table[:balance_cents]
  end

  ransacker :limit, formatter: proc { |v| v.to_i * 100 } do |parent|
    parent.table[:limit_cents]
  end

  def self.amount_used_gteq(amount)
    code_ids = all.map do |code|
      code.id if code.usages.sum(:amount_cents) >= (amount.to_i * 100)
    end.compact
    Code.where(id: code_ids)
  end

  def self.amount_used_lteq(amount)
    code_ids = all.map do |code|
      code.id if code.usages.sum(:amount_cents) <= (amount.to_i * 100)
    end.compact
    Code.where(id: code_ids)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[amount_used_gteq amount_used_lteq]
  end

  def legacy?
    legacy_identifier.present?
  end

  def active?
    self[:external_id].present? && self[:deactivated_at].blank?
  end

  def show_organization_logo?
    product_category.use_organization_branding && organization.logo.attached?
  end

  def card_number
    encrypted_card_number.present? ? decrypt(:card_number, encrypted_card_number) : external_id
  end

  def pin
    encrypted_pin.present? ? decrypt(:pin, encrypted_pin) : extended_account_number
  end

  def card_number_formatted
    card_number.nil? ? '' : card_number.chars.each_slice(4).map(&:join).join(' ')
  end

  def extended_account_number
    return pin if encrypted_pin.present?
    # Thar be legacy
    return '' unless fields && fields['extended_account_number'] # fields does not have a default value

    begin
      ::FirstData::Encryption.decrypt_ean(fields['extended_account_number'])&.strip
    rescue StandardError
      ''
    end
  end

  def expiration_date
    I18n.l(expires_on, format: :mmddyyyy)
  end

  def code_identifier
    legacy_identifier.present? ? legacy_identifier : id
  end

  def redemption_instructions
    product_category.redemption_instructions.where(organization_id: organization.id, active: true)
  end

  concerning :Async do
    def activate
      Cards::ActivateJob.perform_later self
    end

    def register
      Cards::RegisterJob.perform_later self
    end

    def lock(reason)
      Cards::LockJob.perform_later self, reason
    end

    def unlock(reason)
      Cards::UnlockJob.perform_later self, reason
    end

    def unload(amount)
      Cards::UnloadJob.perform_now self, amount.to_s
    end

    def deactivate
      unload balance
      super # aasm
      update status: :deactivated
    end
  end

  concerning :CardProvider do
    class UnknownCardProvider < RuntimeError; end

    def uses_provider?
      product_category.card_type.present? && product_category.card_type != "legacy" # RF: make this first-class direct association on code
    end

    def card_provider
      return unless uses_provider?

      case product_category.card_type.to_sym
      when :first_data
        ::ClosedLoop::Card
      when :eml
        ::EML::Card
      else
        raise UnknownCardProvider, "Card Provider #{product_category&.card_type} Unknown"
      end.send(:from_code, self)
    end
  end

  concerning :Statuses do
    def registered
      update status: :registered
    end

    def activated(card)
      pin = begin
              ::FirstData::Encryption.decrypt_ean(card&.fields['extended_account_number'])&.strip
            rescue StandardError
              ''
            end
      update(external_id: card.id, card_number: card.id, pin: pin, balance: card.balance.to_money, status: :activated, fields: card.fields, pan: card.pan)
      broadcast(:code_activation_success, self)
      register
    end

    def delivered!
      update delivered: true
    end

    def locked
      update status: :locked
    end

    def closed
      update status: :closed
    end

    def used
      update status: (balance.positive? ? :partially_used : :used)
    end

    def unloaded(amount)
      update balance: [balance - amount, 0].max, unloaded_amount: amount
      member.credit_pool(amount: amount, source: self)
    end

    def detect_status_based_on_balance
      if balance.zero?
        :used
      elsif balance.eql?(limit)
        :activated
      else
        :partially_used
      end
    end
  end

  concerning :Listeners do
    included do
      after_initialize do
        subscribe(self, prefix: 'on')
      end
    end

    def on_code_activation_success(code)
      Codes::GenerateCodePdfJob.perform_later(code)
    end
  end

  concerning :PDF do
    def generate_order_pdf_if_all_codes_activated(code)
      return # FIXME: perf reasons, turning off
      order = code.order
      all_activated = order.codes.all? { |record| %w[activated registered].include?(record.status) }
      Orders::GenerateCodePdfForOrderJob.perform_later(order) if all_activated
    end
  end
end
