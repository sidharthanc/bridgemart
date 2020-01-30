require 'csv'

class Employer < Importer
  def initialize(filepath, notify: false, dryrun: false)
    @notify = notify
    super filepath, dryrun: dryrun
  end

  private
    def create_schema_records(record)
      @record = record
      create_user
      create_organization
    end

    def create_organization
      organization = Organization.new organization_params
      @organization = Organization.find_by(legacy_identifier: organization.legacy_identifier)
      if @organization
        log_exception RuntimeError.new("Organization #{organization.legacy_identifier} already exists"), @record
        return
      end
      organization.save!
      @user.organizations << organization
      organization.address = Address.new(address_params)
      @organization = organization
    end

    def organization_params
      {
        name: @record.fetch('Company Name'),
        created_at: sign_up_date(@record.fetch('Sign Up Date')),
        legacy_identifier: legacy_identifier,
        industry: industry_type(@record.fetch('Industry Type')),
        number_of_employees: @record.fetch('Number of Employees'),
        primary_user_id: @user.id,
        credits: [Credit.new(amount: @record.fetch('Starting Credit'))]
      }
    end

    def legacy_identifier
      employer_id = @record.fetch('Employer ID')
      [employer_id, location_id].without(nil, '').join('-')
    end

    def location_id
      @record.fetch('Location ID')
    end

    def sign_up_date(date_string)
      date_string.blank? ? Date.current : Date.strptime(date_string, '%m/%d/%Y')
    end

    def industry_type(industry_string)
      industry_string.blank? ? 'Other' : industry_string
    end

    def address_params
      {
        city: @record.fetch('City'),
        state: @record.fetch('State'),
        street1: @record.fetch('Address 1'),
        street2: @record.fetch('Address 2'),
        zip: @record.fetch('Zip')
      }
    end

    def create_user
      user = User.new user_params
      @user = User.find_by(email: user.email)

      if @user
        log_exception RuntimeError.new("User #{user.email} already exists"), @record
        return
      end

      user.password = 'UserSetupWillGenerateANewPassword'
      user.save!
      user_setup = UserSetup.new(user)

      user_setup.send_invitation_email if notify?
      user.reload
      @user = user
    end

    def user_params
      full_name = @record.fetch('Primary Contact')
      if full_name.present?
        first_name, last_name = full_name.split
        first_name = UNKNOWN if first_name.blank?
        last_name = UNKNOWN if last_name.blank?
      else
        first_name = UNKNOWN
        last_name = UNKNOWN
      end

      {
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone_number: format_phone_number(@record.fetch('Phone'))
      }
    end

    def email
      email = @record.fetch('Email Address')
      return if email.blank?

      if location_id.present?
        email_first, email_last = email.split('@')
        return "#{email_first}+#{location_id}@#{email_last}"
      end

      email
    end

    def format_phone_number(phone)
      unless phone.present?
        log_exception RuntimeError.new('Phone number missing'), @record
        return
      end

      value = phone.scan /\d+/
      phone_number = value.length == 3 ? format('(%.3s) %.3s-%.4s', *value) : ''
      valid_phone_number?(phone_number) ? phone_number : ''
    end

    def valid_phone_number?(phone)
      phone.match? /\(\d{3}\) \d{3}-\d{4}/
    end

    def notify?
      @notify
    end
end
