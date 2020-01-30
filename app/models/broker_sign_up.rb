class BrokerSignUp < SignUp
  attr_accessor :multi_org_user

  def save(context: :create)
    return false unless super

    assign_to_multi_org_user
    true
  end

  private
    def assign_to_multi_org_user
      multi_org_user.organizations << @organization unless multi_org_user.organizations.include?(@organization)
    end

    def ensure_unique_contact_email_across_users
      return if primary_contact_manages_multiple_organizations?

      errors.add :email, :taken if User.where.not(id: user).exists? email: email
    end
end
