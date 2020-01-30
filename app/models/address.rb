class Address < ApplicationRecord
  VALID_STATES = CS.states(:us).keys.map(&:to_s).freeze
  VALID_ZIP_REGEX = /\A[0-9]{5}(?:-[0-9]{4})?\z/.freeze

  belongs_to :addressable, polymorphic: true

  validates :street1, :city, :state, :zip, presence: true
  validates :street1, length: { maximum: 255 }
  validates :state, inclusion: { in: VALID_STATES }
  validates :zip, format: { with: VALID_ZIP_REGEX, message: :zip_code_invalid }, on: :create
end
