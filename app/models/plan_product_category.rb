class PlanProductCategory < ApplicationRecord
  # Refactor Notes: This join table / record is the 'Product' being purchased for
  # each member with each `Code` representing an individual purchased item.

  acts_as_paranoid

  belongs_to :plan
  belongs_to :product_category
  has_one :organization, through: :plan
  has_many :codes, dependent: :destroy
  has_many :special_offers, through: :product_category
  has_many :redemption_instructions, through: :product_category

  enum usage_type: { multi_use: 'multi_use', single_use: 'single_use' }

  monetize :budget_cents
  validates :budget_cents, presence: true #, inclusion: { in: ->(record) { record.product_category.price_points.minimum(:limit).to_money.cents..record.product_category.price_points.maximum(:limit).to_money.cents }, message: "invalid budget amount!" }, on: :update

  default_scope { includes(:product_category) }

  delegate :name, :description, :icon, :background_color, to: :product_category

  def product_fee
    build_fee(budget, name)
  end

  def bridge_fee
    rate = 0.0

    if product_category.flat_rate?
      rate = product_category.flat_fee
    elsif product_category.percentage_rate?
      rate = (product_category.percentage_fee / 100.0) * budget
    end

    build_fee(rate, I18n.t('fee.bridge_fee', charge_description: product_fee.description))
  end

  private
    def build_fee(rate, description)
      Fee.new.tap do |fee|
        fee.rate = rate
        fee.description = description
      end
    end
end
