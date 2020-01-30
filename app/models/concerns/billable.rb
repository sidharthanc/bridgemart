module Billable
  extend ActiveSupport::Concern

  included do
    has_one :billing_contact, as: :billable
    validates_associated :billing_contact
    validates :billing_contact, presence: true, if: :require_billing_contact?

    accepts_nested_attributes_for :billing_contact
  end

  def require_billing_contact?
    true
  end
end
