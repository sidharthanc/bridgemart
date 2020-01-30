class Payment < FormObject
  ACH_ACCOUNT_TYPES = %i[checking savings].freeze

  attribute :order
  attribute :payment_method

  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :street1
  attribute :street2
  attribute :city
  attribute :state
  attribute :zip

  attribute :ach_account_name
  attribute :ach_account_token
  attribute :ach_account_type
  attribute :ach_payment_terms

  attribute :credit_card_token
  attribute :credit_card_expiration_date
  attribute :credit_card_cvv
  attribute :credit_payment_terms

  attribute :billing_id
  attribute :payment_type
  attribute :customer_vault_id
  attribute :terms_and_conditions
  attribute :signature
  attribute :po_number
  attribute :notes
  attribute :applied_credits

  validates :street1, :city, :state, :zip, presence: true

  def save
    return false unless valid?

    order.payment_method = find_payment_method(order)
    order.payment_method.save!
    order.save && verify_agreement(order.organization)
    order.organization.save!
    order.valid? && valid?
  end

  def payment_method_from_billing_id(billing_id, organization)
    payment_method = PaymentMethod.find_or_initialize_by(billing_id: billing_id, organization_id: organization.id)
    address = payment_method.address || organization.address
    if address
      self.street1 = address.street1
      self.street2 = address.street2
      self.city = address.city
      self.state = address.state
      self.zip = address.zip
    end
    payment_method
  end

  private
    def address_params_for(_payment_method)
      {
        street1: street1,
        street2: street2,
        city: city,
        state: state,
        zip: zip
      }
    end

    def billing_contact_params_for(_payment_method)
      {
        first_name: first_name,
        last_name: last_name,
        email: email
      }
    end

    def find_payment_method(order)
      payment_method = billing_id.blank? ? PaymentMethod.new : payment_method_from_billing_id(billing_id, order.organization)
      payment_method.organization = order.organization

      # This next line would update an existing record, do we really want that?
      payment_method.assign_attributes(payment_method_params_for(order))

      if payment_method.persisted?
        if payment_method.billing_contact
          payment_method.billing_contact.update(billing_contact_params_for(payment_method))
        else
          payment_method.billing_contact_attributes = billing_contact_params_for payment_method
        end

        payment_method.address.update(address_params_for(payment_method))
      else
        payment_method.billing_contact_attributes = billing_contact_params_for payment_method
        payment_method.address_attributes = address_params_for payment_method
      end

      payment_method
    end

    def payment_method_params_for(_order)
      {
        billing_id: billing_id,
        customer_vault_id: customer_vault_id,
        ach_account_name: ach_account_name,
        ach_account_token: ach_account_token,
        ach_account_type: ach_account_type,
        credit_card_token: credit_card_token,
        credit_card_expiration_date: format_credit_card_expiration_date(credit_card_expiration_date),
        credit_card_cvv: credit_card_cvv
      }.compact.reject { |_k, v| v.blank? }
    end

    def verify_agreement(organization)
      organization.signatures.find_or_create_by(commercial_agreement: organization.active_agreement)
    end

    def format_credit_card_expiration_date(v)
      v&.delete('/')
    end
end
