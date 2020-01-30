class Broker < SignUp
  attribute :broker_organization_name

  validates :first_name, :last_name, :email, :broker_organization_name, presence: true
  validates :phone, format: { with: /\(\d{3}\) \d{3}-\d{4}/ }, allow_blank: true
  validate :ensure_unique_contact_email_across_users

  def save
    return false if invalid?

    @user = create_user
    set_permissions
    true
  end

  private
    def create_user
      User.create(
        email: email,
        password: generated_password,
        first_name: first_name,
        last_name: last_name,
        phone_number: phone,
        broker_organization_name: broker_organization_name
      )
    end

    def set_permissions
      @user.permission_groups = PermissionGroup.default_for_broker
    end

    def ensure_unique_contact_email_across_users
      errors.add :email, :taken if User.where.not(id: user).exists? email: email
    end
end
