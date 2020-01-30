describe ApplicationPolicy do
  subject { described_class.new user, record }
  let(:user) { users(:joseph) }
  let(:record) { Plan.new }

  before do
    user.permission_groups = [permission_group]
  end

  describe '#update?' do
    context 'with update permissions' do
      let(:permission_group) { permission_groups(:admin) }

      it 'should return true' do
        expect(subject.update?).to be true
      end
    end

    context 'without permissions' do
      let(:permission_group) { permission_groups(:none) }

      it 'should return false' do
        expect(subject.update?).to be false
      end
    end
  end

  describe '#create?' do
    context 'with create permissions' do
      let(:permission_group) { permission_groups(:admin) }

      it 'should return true' do
        expect(subject.create?).to be true
      end
    end

    context 'without permissions' do
      let(:permission_group) { permission_groups(:none) }

      it 'should return false' do
        expect(subject.update?).to be false
      end
    end
  end
end
