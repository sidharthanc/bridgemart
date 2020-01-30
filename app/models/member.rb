class Member < ApplicationRecord
  acts_as_paranoid

  include HasAddress
  include Deactivatable
  include TokenAuthenticatable
  include ActionView::Helpers::TagHelper

  belongs_to :order
  has_one :plan, through: :order
  has_one :organization, through: :plan
  has_many :codes, dependent: :destroy
  has_many :usages, through: :codes
  has_one_attached :barcode_image

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true

  validates :first_name, :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: Devise.email_regexp
  validates :phone, format: { with: /\(\d{3}\) \d{3}-\d{4}/, message: :phone_format_error }, allow_blank: true

  counter_culture :order
  counter_culture %i[order plan]
  counter_culture %i[order plan organization]

  delegate :credit_pool, to: :creditable_to
  audited

  scope :chronological, -> { order(:created_at) }

  ransack_alias :member, :first_name_or_middle_name_or_last_name_or_phone_or_email_or_id

  before_validation :mark_address_for_removal
  before_save :prefill_address

  def mark_address_for_removal
    address.mark_for_destruction if address && %w[street1 street2 city state zip].all? { |attr| address.send(attr).blank? }
  end

  def sorted_codes
    codes.order('created_at DESC')
  end

  def prefill_address
    return if address.presence || !organization&.address.presence

    build_address organization.address.dup.as_json
  end

  # TODO: If this does not scale, replace the ransacker with a table column containing the stringized id value
  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '9999999999')")
  end

  def name(middle: true)
    [].tap do |n|
      n << first_name
      n << middle_name if middle # << will append in a nil
      n << last_name
    end.join(' ')
  end

  def require_address?
    false
  end

  def self.with_usage
    joins(:usages).distinct
  end

  def self.usage_percentage_as_decimal
    (with_usage.count.to_f / (count.nonzero? || 1).to_f)
  end

  def format_special_offer_usage_instructions_for_mail
    content_tag(:ul, order.special_offers.reduce('') do |text, special_offer|
      text + content_tag(:li, special_offer.usage_instructions)
    end.html_safe)
  end

  def first_data?
    codes.with_card_type(:first_data).any?
  end

  private
    def creditable_to
      organization
    end
end
