class LineItem < ApplicationRecord
  acts_as_paranoid
  belongs_to :order
  has_one :organization, through: :order
  belongs_to :source, polymorphic: true, optional: true

  enum charge_type: %i[charge fee credit]

  monetize :amount_cents

  scope :applied_credits, -> { where charge_type: :credit }
  scope :charges, -> { where charge_type: :charge }
  scope :fees, -> { where charge_type: :fee }
end
