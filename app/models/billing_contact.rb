class BillingContact < ApplicationRecord
  audited
  belongs_to :billable, polymorphic: true
  validates :email, presence: true, format: Devise.email_regexp
end
