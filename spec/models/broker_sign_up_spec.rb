RSpec.describe BrokerSignUp, type: :model do
  let(:broker_user) { users(:broker) }
  let(:valid_params) do
    {
      first_name: 'first_name',
      last_name: 'last_name',
      email: 'email@example.com',
      title: 'Member',
      phone: '(123) 456-7890',
      organization_name: 'Org Name',
      industry: 'Auto',
      approx_employees_count: '100-500',
      approx_employees_with_safety_prescription_eyewear_count: 'Less than 100',
      product_category_ids: [ProductCategory.first.id],
      multi_org_user: broker_user
    }
  end

  before do
    attach_images_to_product_categories
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name).on(:create) }
    it { is_expected.to validate_presence_of(:last_name).on(:create) }
    it { is_expected.to validate_presence_of(:email).on(:create) }
    it { is_expected.to validate_presence_of(:organization_name).on(:create) }
    it { is_expected.to validate_presence_of(:industry).on(:create) }
    it { is_expected.to validate_length_of(:product_category_ids) }

    it { is_expected.to allow_value(nil).for(:phone).on(:create) }
    it { is_expected.to allow_value('(000) 000-0000').for(:phone).on(:create) }
    it { is_expected.to_not allow_value('Dave').for(:phone).on(:create) }

    context 'when the primary contact is a broker' do
      it 'does not validate uniqueness of contact e-mail across users' do
        subject.email = broker_user.email
        expect(subject.errors.details[:email]).to be_empty
      end
    end

    context 'when the primary contact is an admin' do
      before { broker_user.permission_groups = [permission_groups(:admin)] }

      it 'does not validates uniqueness of contact e-mail across users' do
        subject.email = broker_user.email
        expect(subject.errors.details[:email]).to be_empty
      end
    end

    it 'validates uniqueness of priamry contact e-mail across users' do
      subject.email = users(:test).email
      expect(subject).to be_invalid :create
      expect(subject.errors.details[:email]).to include error: :taken
    end
  end

  describe '#initialize' do
    it 'assigns the attributes' do
      sign_up = BrokerSignUp.new(valid_params)
      expect(sign_up).to have_attributes(
        first_name: 'first_name',
        last_name: 'last_name',
        email: 'email@example.com',
        title: 'Member',
        phone: '(123) 456-7890',
        organization_name: 'Org Name',
        approx_employees_count: '100-500',
        approx_employees_with_safety_prescription_eyewear_count: 'Less than 100',
        product_category_ids: [ProductCategory.first.id]
      )
    end
  end

  describe '#save' do
    context 're-enrollment (adding product categories)' do
      let(:sign_up) { BrokerSignUp.new(valid_params) }
      let(:plan) { plans(:metova) }
      let(:organization) { plan.organization }
      let(:user) { organization.primary_user }

      before do
        sign_up.plan = plan
        sign_up.user = user
        sign_up.organization = organization
      end

      it 'does not update the product categories if information is invalid' do
        sign_up.product_category_ids = []
        expect(sign_up).to be_invalid :re_enrollment
        expect { sign_up.save }.to_not change(plan, :product_categories)
      end

      it 'returns false if information is invalid' do
        sign_up.product_category_ids = []
        expect(sign_up.save).to be false
      end

      it 'saves the product categories if information is valid' do
        sign_up.product_category_ids = [ProductCategory.last.id]
        expect(sign_up).to be_valid :re_enrollment
        sign_up.save context: :re_enrollment
        expect(sign_up.plan.reload.product_categories).to eq [ProductCategory.last]
      end
    end

    context 'signing up for the first time' do
      context 'when the primary contact is a broker' do
        let(:broker_valid_params) { valid_params.update(email: broker_user.email) }

        it 'does not create a new user' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to_not change(User, :count)
        end

        it 'assigns broker as the org primary contact' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to_not change(User, :count)
        end

        it 'grants default permissions' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          sign_up.save
          expect(sign_up.user.permission_groups).to contain_exactly PermissionGroup.default(:broker).first, PermissionGroup.default(:organization).first
        end
        it 'returns false if information is invalid' do
          sign_up = BrokerSignUp.new
          expect(sign_up).to be_invalid :create
          expect(sign_up.save).to eq false
        end

        it 'does not create an organization and plan if information is invalid' do
          sign_up = BrokerSignUp.new
          expect(sign_up).to be_invalid :create
          expect do
            sign_up.save
          end.to_not(change { [Plan.count, Organization.count] })
        end

        it 'creates a plan if the information is valid' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Plan, :count).by(1)
        end

        it 'creates a order if the information is valid' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Order, :count).by(1)
        end

        it 'creates an organization if the information is valid' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Organization, :count).by(1)
          org = Organization.find_by(name: 'Org Name')
          expect(org.primary_user).to eq broker_user
          expect(org.users).to eq [broker_user]
        end

        it 'returns true if the save was successful' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          expect(sign_up).to be_valid
          expect(sign_up.save).to be true
        end

        it 'sets the user and plan attributes' do
          sign_up = BrokerSignUp.new(broker_valid_params)
          sign_up.save
          expect(sign_up.plan).to eq(Plan.last)
          expect(sign_up.user).to eq(broker_user)
        end
      end

      context 'when the primary contact is a new user' do
        it 'returns false if information is invalid' do
          sign_up = BrokerSignUp.new
          expect(sign_up).to be_invalid :create
          expect(sign_up.save).to eq false
        end

        it 'does not create a user, organization, and plan if information is invalid' do
          sign_up = BrokerSignUp.new
          expect(sign_up).to be_invalid :create
          expect do
            sign_up.save
          end.to_not(change { [User.count, Plan.count, Organization.count] })
        end

        it 'creates a user if the information is valid' do
          sign_up = BrokerSignUp.new(valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(User, :count).by(1)
        end

        it 'creates a plan if the information is valid' do
          sign_up = BrokerSignUp.new(valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Plan, :count).by(1)
        end

        it 'creates a order if the information is valid' do
          sign_up = BrokerSignUp.new(valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Order, :count).by(1)
        end

        it 'creates an organization if the information is valid' do
          sign_up = BrokerSignUp.new(valid_params)
          expect(sign_up).to be_valid
          expect { sign_up.save }.to change(Organization, :count).by(1)
          org = Organization.find_by(name: 'Org Name')
          expect(org.primary_user).to eq sign_up.user
          expect(org.users).to include sign_up.user, broker_user
        end

        it 'grants default permissions' do
          sign_up = BrokerSignUp.new(valid_params)
          sign_up.save
          expect(sign_up.user.permission_groups).to match PermissionGroup.default(:organization)
          expect(broker_user.permission_groups).to match PermissionGroup.default(:broker)
        end

        it 'returns true if the save was successful' do
          sign_up = BrokerSignUp.new(valid_params)
          expect(sign_up).to be_valid
          expect(sign_up.save).to be true
        end

        it 'sets the user and plan attributes' do
          sign_up = BrokerSignUp.new(valid_params)
          sign_up.save
          expect(sign_up.plan).to eq(Plan.last)
          expect(sign_up.user).to eq(User.last)
        end
      end
    end
  end
end
