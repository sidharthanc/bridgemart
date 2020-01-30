class PermissionGroup < ApplicationRecord
  has_many :permissions
  has_many :permission_group_ownerships, foreign_key: :owner_id, inverse_of: :owner
  has_many :owned_permission_groups, through: :permission_group_ownerships, source: :permission_group
  has_and_belongs_to_many :users

  scope :admin, -> { where(admin: true) }
  scope :default, ->(context) { where(default_for: context) }

  enum default_for: %i[none organization broker], _prefix: true

  def admin!
    self.admin = true
  end

  def not_admin!
    self.admin = false
  end
end
