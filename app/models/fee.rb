class Fee < ApplicationRecord
  monetize :rate_cents

  validates :description, :rate_cents, presence: true

  audited
end
