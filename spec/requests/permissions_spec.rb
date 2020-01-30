describe 'Permissions', type: :request do
  as { user }
  let(:user) { users(:joseph) }

  describe 'Dashboard' do
    context 'with an unprivileged user' do
      before { unprivileged! }

      it 'should hide the crud links' do
        visit dashboard_path
        expect(page).to have_no_link I18n.t('pages.dashboard.products.edit')
        expect(page).to have_no_link I18n.t('pages.dashboard.members.edit')
      end
    end
  end

  describe 'Members' do
    context 'with an unprivileged user' do
      before { unprivileged! }

      it 'should hide the crud links' do
        visit organization_members_path(organizations(:metova))
        expect(page).to have_no_link I18n.t('members.index.new_member')
        expect(page).to have_no_link I18n.t('members.index.actions.edit')
        expect(page).to have_no_link I18n.t('members.index.actions.resend')
        expect(page).to have_no_link I18n.t('members.index.actions.deactivate')
      end
    end
  end

  def unprivileged!
    user.update! permission_groups: [permission_groups(:none)]
  end
end
