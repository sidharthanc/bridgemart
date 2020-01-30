class SpecialOffer < ApplicationRecord
  acts_as_paranoid

  belongs_to :product_category
  has_and_belongs_to_many :orders

  has_one_attached :image
end
