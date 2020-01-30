RSpec.describe Broker, type: :model do
  let(:valid_params) do
    {
      first_name: 'first_name',
      last_name: 'last_name',
      email: 'newbroker@example.com',
      phone: '(123) 456-7890',
      broker_organization_name: 'Broker Org Name'
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name).on(:create) }
    it { is_expected.to validate_presence_of(:last_name).on(:create) }
    it { is_expected.to validate_presence_of(:email).on(:create) }
    it { is_expected.to validate_presence_of(:broker_organization_name).on(:create) }

    it { is_expected.to allow_value(nil).for(:phone).on(:create) }
    it { is_expected.to allow_value('(000) 000-0000').for(:phone).on(:create) }
    it { is_expected.to_not allow_value('Dave').for(:phone).on(:create) }

    it 'validates uniqueness of contact e-mail across users' do
      subject.email = users(:test).email
      expect(subject).to be_invalid :create
      expect(subject.errors.details[:email]).to include error: :taken
    end
  end

  describe '#initialize' do
    it 'assigns the attributes' do
      sign_up = Broker.new(valid_params)
      expect(sign_up).to have_attributes(
        first_name: 'first_name',
        last_name: 'last_name',
        email: 'newbroker@example.com',
        phone: '(123) 456-7890',
        broker_organization_name: 'Broker Org Name'
      )
    end
  end

  describe '#save' do
    context 'signing up as a broker' do
      it 'returns false if information is invalid' do
        sign_up = Broker.new
        expect(sign_up).to be_invalid :create
        expect(sign_up.save).to eq false
      end

      it 'does not create a user if information is invalid' do
        sign_up = Broker.new
        expect(sign_up).to be_invalid :create
        expect { sign_up.save }.to_not(change { User.count })
      end

      it 'grants default permissions' do
        sign_up = Broker.new(valid_params)
        sign_up.save
        expect(sign_up.user.permission_groups).to match PermissionGroup.default(:broker)
      end

      it 'returns true if the save was successful' do
        sign_up = Broker.new(valid_params)
        expect(sign_up).to be_valid
        expect(sign_up.save).to be true
      end

      it 'sets the user and plan attributes' do
        sign_up = Broker.new(valid_params)
        sign_up.save
        expect(sign_up.user).to eq(User.find_by(email: 'newbroker@example.com'))
      end
    end
  end
end
