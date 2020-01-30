module HasAddress
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable
    validates_associated :address
    validates :address, presence: true, if: :require_address?

    accepts_nested_attributes_for :address
  end

  def require_address?
    true
  end
end
