class OrganizationUser < ApplicationRecord
  acts_as_paranoid

  belongs_to :organization
  belongs_to :user
end
