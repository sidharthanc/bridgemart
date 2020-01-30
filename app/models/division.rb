class Division < ApplicationRecord
  has_one_attached :logo
  has_many :product_categories

  validates :name, presence: true
end
