describe Seeds::PredefinedRoles do
  describe '#seed!' do
    context 'without existing roles' do
      before { PermissionGroup.destroy_all }

      it 'should create the default roles' do
        expect { subject.seed! }.to change { PermissionGroup.count }.by 6
      end
    end

    context 'with existing roles' do
      it 'should create the new roles' do
        expect { subject.seed! }.to change { PermissionGroup.count }.by 2
      end

      context 'with differences' do
        before { permission_group.update! default_for: :none }
        let(:permission_group) { permission_groups(:organization) }

        it 'should update the record' do
          expect { subject.seed! }.to change {
            permission_group.reload.default_for
          }.from('none').to('organization')
        end
      end
    end
  end
end
