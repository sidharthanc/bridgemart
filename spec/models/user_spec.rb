RSpec.describe User, type: :model do
  it { is_expected.to have_many(:organization_users) }
  it { is_expected.to have_many(:organizations) }
  it { is_expected.to have_and_belong_to_many(:permission_groups) }
  it { is_expected.to be_auditable }

  context 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('(000) 000-0000').for(:phone_number) }
    it { is_expected.to_not allow_value('000-000-0000').for(:phone_number) }
  end

  context 'delete user' do
    let(:primary_user) { users(:andrew) }
    let(:non_primary_user) { users(:test) }

    it 'should return primary user as true' do
      expect(primary_user.primary_user?).to be true
    end

    it 'should return non-primary user as false' do
      expect(non_primary_user.primary_user?).to be false
    end

    it 'should not delete primary_user' do
      expect { primary_user.destroy }.to change(User, :count).by(0)
    end

    it 'should delete non-primary user' do
      expect { non_primary_user.destroy }.to change(User, :count).by(-1)
    end
  end

  describe '#can_access_org?' do
    let(:organization) { organizations(:metova) }

    context 'as an admin' do
      let(:user) { users(:admin) }

      it 'returns true' do
        expect(user.can_access_org?(organization)).to be true
      end
    end

    context 'as an broker' do
      let(:user) { users(:broker) }

      context 'with acccess to the organization' do
        before { user.organizations << organization }

        it 'returns true' do
          expect(user.can_access_org?(organization)).to be true
        end
      end

      context 'without acccess to the organization' do
        it 'returns false' do
          expect(user.can_access_org?(organization)).to be false
        end
      end
    end

    context 'as a primary user' do
      let(:user) { users(:joseph) }

      it 'returns true' do
        expect(user.can_access_org?(organization)).to be true
      end
    end

    context 'as an unrelated user' do
      let(:user) { users(:test) }

      it 'returns false' do
        expect(user.can_access_org?(organization)).to be false
      end
    end
  end
end
