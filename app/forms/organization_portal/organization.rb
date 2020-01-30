module OrganizationPortal
  class Organization < FormObject
    attribute :contact_first_name
    attribute :contact_last_name
    attribute :contact_email
    attribute :contact_phone
    attribute :contact_password
    attribute :organization_name
    attribute :organization_industry
    attribute :organization_number_of_employees
    attribute :number_of_employees_with_safety_rx_eyewear
    attribute :street1
    attribute :street2
    attribute :city
    attribute :state
    attribute :zip
    attribute :user
    attribute :organization
    attribute :address
    attribute :billing_contact

    validates :organization_name, :organization_industry, presence: true
    validates :contact_phone, format: { with: /\(\d{3}\) \d{3}-\d{4}/, message: :phone_format_error }, allow_blank: true
    validate :ensure_unique_contact_email_across_users

    def save
      return false unless valid?

      update_user
      update_address
      update_organization
      true
    end

    def persisted?
      true
    end

    def self.find(organization_id)
      organization = ::Organization.find organization_id
      user = organization.primary_user

      new(
        user: user,
        contact_phone: user.phone_number,
        organization: organization,
        organization_name: organization.name,
        organization_industry: organization.industry,
        organization_number_of_employees: organization.number_of_employees,
        number_of_employees_with_safety_rx_eyewear: organization.number_of_employees_with_safety_rx_eyewear,
        address: organization.address,
        street1: organization&.address&.street1,
        street2: organization&.address&.street2,
        city: organization&.address&.city,
        zip: organization&.address&.zip,
        state: organization&.address&.state
      )
    end

    def self.update_attributes(organization_id, attributes)
      organization = find(organization_id)
      if organization.address.present?
        organization.address.attributes = attributes.slice(:street1, :street2, :zip, :city, :state)
      else
        address = Address.new(attributes.slice(:street1, :street2, :zip, :city, :state))
        address.addressable_id = organization.organization.id
        address.addressable_type = 'Organization'
        organization.address = address
      end
      organization.attributes = attributes
      organization
    end

    private
      def update_user
        user.update(
          phone_number: contact_phone
        )
      end

      def update_address
        address.update(
          street1: address.street1,
          street2: address.street2,
          zip: address.zip,
          city: address.city,
          state: address.state
        )
      end

      def update_organization
        organization.update(
          name: organization_name,
          industry: organization_industry,
          number_of_employees: organization_number_of_employees,
          number_of_employees_with_safety_rx_eyewear: number_of_employees_with_safety_rx_eyewear,
          primary_user_id: user.id
        )

        # TODO: Possibly add notification here when the organization changes, post-invoicing
      end

      def ensure_unique_contact_email_across_users
        errors.add(:contact_email, :taken) if User.where.not(id: user).exists?(email: contact_email)
      end
  end
end
