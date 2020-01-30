class User < ApplicationRecord
  include Memoizer

  acts_as_paranoid
  audited
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  has_many :organization_users
  has_many :organizations, through: :organization_users
  has_many :organization_members, through: :organizations, source: :members
  has_many :plans, through: :organizations
  has_many :orders, through: :organizations

  validates :email, :first_name, :last_name, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validates :phone_number, format: { with: /\(\d{3}\) \d{3}-\d{4}/, message: :phone_format_error }, allow_blank: true

  scope :chronological, -> { order(:created_at) }

  before_destroy { throw(:abort) if primary_user? }

  ransack_alias :user, :first_name_or_last_name_or_phone_number_or_email_or_id

  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '9999999999')")
  end

  concerning :Permissions do
    included do
      has_and_belongs_to_many :permission_groups
      has_many :owned_permission_groups, through: :permission_groups

      scope :with_default_permission_for_organization, -> { includes(:permission_groups).where(permission_groups: { id: PermissionGroup.default_for_organization }) }

    end
  end

  def permission_groups
    if super.any?
      super
    else
      PermissionGroup.default_for_organization
    end
  end
  memoize :permission_groups

  def admin?
    Rails.cache.fetch("permissions/#{cache_key}/admin?", expires_in: 1.hour) do
      permission_groups.admin.any?
    end
  end
  memoize :admin?

  def broker?
    Rails.cache.fetch("permissions/#{cache_key}/broker?", expires_in: 1.hour) do
      permission_groups.default_for_broker.any?
    end
  end
  memoize :broker?

  def primary_user?
    Rails.cache.fetch("permissions/#{cache_key}/primary_user?", expires_in: 1.hour) do
      organizations.where(primary_user: self).present?
    end
  end
  memoize :primary_user?

  def full_name
    "#{first_name} #{last_name}"
  end

  def permission_group_names
    Rails.cache.fetch("permissions/#{cache_key}/permission_group_names", expires_in: 1.hour) do
      permission_groups.pluck(:name).join(', ')
    end
  end

  def managing_multiple_organizations?
    Rails.cache.fetch("permissions/#{cache_key}/managing_multiple_organizations?", expires_in: 1.hour) do
      admin? || broker? || organizations.many?
    end
  end
  memoize :managing_multiple_organizations?

  def can_access_org?(organization)
    Rails.cache.fetch("permissions/#{cache_key}/#{organization.id}/can_access_org?", expires_in: 1.hour) do
      admin? || (organizations.include?(organization) && broker?) || self == organization.primary_user
    end
  end
  memoize :can_access_org?

  def multiple_organizations
    admin? ? Organization.all : organizations
  end
  memoize :multiple_organizations
end
