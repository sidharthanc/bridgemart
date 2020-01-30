class RedemptionInstruction < ApplicationRecord
  acts_as_paranoid

  belongs_to :organization
  belongs_to :product_category

  validates :title, :description, presence: true

  before_destroy { throw(:abort) if active? }
  after_update { check_and_update_last_active }

  def check_and_update_last_active
    update(active: true) if active_instructions.empty?
  end

  def last_active_instruction?
    active? && active_instructions.size <= 1
  end

  def active_instructions
    RedemptionInstruction.where(
      organization: organization,
      active: true,
      product_category: product_category
    )
  end
end
