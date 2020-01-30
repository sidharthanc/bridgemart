class Plan < ApplicationRecord
  # Refactor Notes:
  # I'm not sure why we need this layer of the abstraction.

  audited
  acts_as_paranoid
  belongs_to :organization

  has_many :plan_product_categories, dependent: :destroy
  has_many :product_categories, through: :plan_product_categories
  has_many :orders, dependent: :destroy
  has_many :members, through: :orders
  has_many :special_offers, through: :plan_product_categories

  accepts_nested_attributes_for :plan_product_categories
  accepts_nested_attributes_for :orders

  def active?
    return false unless starts_on && ends_on

    Time.current.between?(starts_on, ends_on)
  end

  def starts_on
    latest_order&.starts_on
  end

  def ends_on
    latest_order&.ends_on
  end

  private
    def latest_order
      orders&.last
    end
end
