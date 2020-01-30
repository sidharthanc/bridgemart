class ProductCategory < ApplicationRecord
  acts_as_paranoid
  audited

  has_many :plan_product_categories
  has_many :plans, through: :plan_product_categories
  has_many :codes, through: :plan_product_categories
  has_many :price_points
  has_one_attached :icon
  has_one_attached :image
  has_many :special_offers
  has_many :redemption_instructions

  belongs_to :division

  enum fee_type: %i[flat_rate percentage_rate]
  enum hidden: %i[visible hidden]
  enum icon_name: %i[exam eyewear fashion safety]
  enum card_type: { first_data: 'first_data', eml: 'eml', legacy: 'legacy' } # default: first_data

  before_destroy { throw(:abort) if plan_product_categories.present? }
 
  validates :name, presence: true
  validates :percentage_fee, presence: true, if: proc { |product_category| product_category.percentage_rate? }
  validates :flat_fee_cents, presence: true, if: proc { |product_category| product_category.flat_rate? }

  validates :card_type, presence: true

  monetize :flat_fee_cents

  accepts_nested_attributes_for :price_points

  after_commit on: %i[create update] do |record|
    record.icon.attach(filename: "missing-image.png", io: File.open(Rails.root.join("app", "assets", "images", "missing-image.png"))) unless icon.attached?
  end

  scope :visible_for_user, ->(user) { user&.admin? ? all : visible }

  def card_name
    I18n.t('product_categories.card_name', name: name)
  end

  def price_boundary(limit_type:)
    price_points.find_by(limit_type: limit_type)
  end
end
