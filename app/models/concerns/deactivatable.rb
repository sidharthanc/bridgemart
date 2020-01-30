module Deactivatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where deactivated_at: nil }
    scope :inactive, -> { where.not deactivated_at: nil }
  end

  def active?
    self[:deactivated_at].blank?
  end

  def inactive?
    !active?
  end

  def deactivate
    return if inactive?

    update_attribute :deactivated_at, Time.current
  end

  def reactivate
    return if active?

    update_attribute :deactivated_at, nil
  end
end
