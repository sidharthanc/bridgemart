RSpec.describe OrganizationPortal::Organization, type: :model do
  let(:plan) { plans(:metova) }
  let(:order) { plan.orders.last }
  let(:billing_contact) { billing_contacts(:metova) }
  let(:organization) { organizations(:metova) }
  let(:user) { organization.primary_user }
  let(:address) { addresses(:logan) }

  before do
    billing_contact.billable = plan
    billing_contact.save!

    organization.plans << plan
    organization.users << user
    organization.save!

    order.update starts_on: 1.day.ago
    plan.organization = organization
    plan.save!
  end

  let(:all_params) do
    {
      contact_first_name: 'first_name',
      contact_last_name: 'last_name',
      contact_email: 'email@example.com',
      contact_phone: '(123) 456-7890',
      organization_name: 'Org Name',
      organization_industry: 'Auto',
      organization_number_of_employees: '100-500',
      number_of_employees_with_safety_rx_eyewear: 'Less than 100',
      street1: '3301 Aspen Grove',
      street2: 'Suite 301',
      city: 'Franklin',
      state: 'TN',
      zip: 12_345
    }
  end

  let(:partial_params) do
    {
      contact_email: 'email@example.com',
      contact_phone: '(123) 456-7890',
      organization_name: 'Org Name',
      street1: '3301 Aspen Grove'
    }
  end

  describe 'validations' do
    it { is_expected.to allow_value(nil).for(:contact_phone) }
    it { is_expected.to allow_value('(000) 000-0000').for(:contact_phone) }
    it { is_expected.to_not allow_value('Dave').for(:contact_phone) }

    it 'validates uniqueness of contact e-mail across users' do
      subject.contact_email = users(:test).email
      expect(subject).to be_invalid
      expect(subject.errors.details[:contact_email]).to include error: :taken
    end
  end

  describe '#initialize' do
    it 'assigns the attributes' do
      op_organization = OrganizationPortal::Organization.find(organization.id)
      expect(op_organization).to have_attributes(
        contact_phone: user.phone_number,
        organization_name: organization.name,
        organization_industry: organization.industry,
        organization_number_of_employees: organization.number_of_employees,
        number_of_employees_with_safety_rx_eyewear: organization.number_of_employees_with_safety_rx_eyewear
      )
    end
  end

  describe '#update_attributes' do
    it 'assigns all attributes' do
      op_organization = OrganizationPortal::Organization.update_attributes(organization.id, all_params)
      expect(op_organization).to have_attributes(
        contact_phone: all_params[:contact_phone],
        organization_name: all_params[:organization_name],
        organization_industry: all_params[:organization_industry],
        organization_number_of_employees: all_params[:organization_number_of_employees],
        number_of_employees_with_safety_rx_eyewear: all_params[:number_of_employees_with_safety_rx_eyewear]
      )
    end

    it 'assigns some attributes' do
      op_organization = OrganizationPortal::Organization.update_attributes(organization.id, partial_params)
      expect(op_organization).to have_attributes(
        contact_phone: partial_params[:contact_phone],
        organization_name: partial_params[:organization_name],
        organization_industry: organization.industry,
        organization_number_of_employees: organization.number_of_employees,
        number_of_employees_with_safety_rx_eyewear: organization.number_of_employees_with_safety_rx_eyewear
      )
    end
  end

  describe '#save' do
    context 'when persisted' do
      let(:op_organization) { OrganizationPortal::Organization.find(organization.id) }

      it 'does not update organization if information is invalid' do
        op_organization.contact_phone = 'HAL 3000'
        op_organization.contact_first_name = nil
        op_organization.organization_name = nil
        op_organization.zip = nil
        expect(op_organization).to be_invalid
        expect { op_organization.save }.to_not change(organization, :name)
        expect(op_organization.save).to be false
      end

      it 'updates a user, organization, and billing_contact if information is valid' do
        op_organization.contact_phone = '(414) 098-7654'
        op_organization.organization_name = 'XYZ Acme'
        expect(op_organization).to be_valid
        expect(op_organization.save).to be true

        expect(user.reload.phone_number).to eq '(414) 098-7654'
        expect(organization.reload.name).to eq 'XYZ Acme'
      end
    end
  end
end
