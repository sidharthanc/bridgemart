class PricePoint < ApplicationRecord
  belongs_to :product_category

  enum limit_type: %i[opening basic mid_range high_end]

  audited
end
