class Signature < ApplicationRecord
  acts_as_paranoid

  belongs_to :organization
  belongs_to :commercial_agreement
end
