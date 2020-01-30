class Permission < ApplicationRecord
  ALL_TARGETS = %i[plan member product_category code user permission permission_group order organization payment_method redemption_instruction].freeze
  FINANCE_TARGETS = %i[payment_method].freeze

  belongs_to :permission_group

  scope :create_permitted, -> { where(create_permitted: true) }
  scope :update_permitted, -> { where(update_permitted: true) }
  scope :in_permission_groups, ->(permission_groups) { where(permission_group: permission_groups) }
  scope :targeting, ->(target) { where(target: target) }
end
