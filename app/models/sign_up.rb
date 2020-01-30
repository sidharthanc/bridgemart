class SignUp
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include Rails.application.routes.url_helpers
  include Skylight::Helpers

  EMPLOYEE_COUNT_RANGES = ['Less than 100', '100-500', '500-1000', '1000-5000', '5000+'].freeze
  INDUSTRIES = ['Agriculture/Agribusiness', 'Auto', 'Charity',
                'Chemical Processing', 'Construction', 'Consumer Products',
                'Education', 'Electronic Assembly', 'Energy', 'Engineering',
                'Entertainment/Recreation', 'Food/Beverage', 'Government',
                'Green Technology', 'Health Care', 'Hotel/Restaurant/Hospitality',
                'Manufacturing', 'Medical/Health', 'Mineral Mining',
                'Molding/Fabrication', 'Oil & Gas Other', 'Packaging and Adhesives',
                'Public Administration', 'Rail', 'Retail', 'Technology',
                'Transportation', 'Trucking', 'Utilities'].freeze

  attr_accessor :user, :organization, :order, :plan

  attribute :first_name
  attribute :last_name
  attribute :title
  attribute :email
  attribute :phone
  attribute :organization_name
  attribute :industry
  attribute :approx_employees_count
  attribute :approx_employees_with_safety_prescription_eyewear_count
  attribute :product_category_ids
  attribute :primary_user_id

  with_options(on: %i[create update]) do |o|
    o.validates :first_name, :last_name, :organization_name, :industry, presence: true
    o.validates :email, format: { with: Devise.email_regexp }, presence: true
    o.validates :phone, format: { with: /\(\d{3}\) \d{3}-\d{4}/ }, allow_blank: true
    o.validate :ensure_unique_contact_email_across_users
  end

  validates :product_categories, length: { minimum: 1 }, on: %i[re_enrollment create update]

  def save(context: :create)
    return false if invalid? context

    Order.transaction do
      @user = find_or_create_user
      @organization ||= create_organization_with_primary_user @user
      set_permissions_for_primary_org_user
      @plan = create_plan_under_organization @organization
      @order = create_order_under_plan @plan
    end
    true
  end

  def generated_password
    Devise.friendly_token.first 8
  end

  private
    def find_or_create_user
      User.find_or_create_by(email: email) do |u|
        u.password = generated_password
        u.first_name = first_name
        u.last_name = last_name
        u.phone_number = phone
        u.title = title
      end
    end
    instrument_method :find_or_create_user

    def create_organization_with_primary_user(user)
      Organization.create(
        name: organization_name,
        industry: industry,
        number_of_employees: approx_employees_count,
        number_of_employees_with_safety_rx_eyewear: approx_employees_with_safety_prescription_eyewear_count,
        primary_user_id: user.id
      ).tap do |org|
        org.users << user if user.persisted?
      end
    end
    instrument_method :create_organization_with_primary_user

    def create_plan_under_organization(organization)
      organization.plans.create product_categories: product_categories
    end
    instrument_method :create_plan_under_organization

    def create_order_under_plan(plan)
      plan.orders.create starts_on: Date.current # FIXME, this should be using the value from the submitted form
    end
    instrument_method :create_order_under_plan

    def product_categories
      if product_category_ids.blank?
        ProductCategory.none
      else
        ProductCategory.where id: product_category_ids.reject(&:blank?)
      end
    end

    def ensure_unique_contact_email_across_users
      errors.add :email, :taken if User.where.not(id: user).exists? email: email
    end

    def set_permissions_for_primary_org_user
      @user.permission_groups += PermissionGroup.default_for_organization
    end

    def primary_contact_manages_multiple_organizations?
      user_by_email = User.find_by(email: email)
      user_by_email&.managing_multiple_organizations?
    end
    instrument_method :primary_contact_manages_multiple_organizations?
end
