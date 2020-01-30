describe 'ActiveAdmin Dashboard', type: :request do
  let(:admin_group) { permission_groups(:admin) }
  let(:user) { users(:joseph) }

  before do
    sign_in user
  end

  context 'non-admin user' do
    it 'redirects the non-admin user to the root path' do
      visit admin_dashboard_path

      expect(page).to have_current_path root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end

  context 'admin user' do
    before do
      user.permission_groups = [admin_group]
    end

    it 'directs the admin user to the admin path' do
      visit admin_dashboard_path

      expect(page).to have_current_path admin_dashboard_path
    end

    it 'has a link to the organizations page' do
      visit admin_dashboard_path

      expect(page).to have_link I18n.t('admin.organizations')
    end

    # NOTE: Service Activity Temporarily Disabled
    xit 'has a listing of recent service activity' do
      visit admin_dashboard_path

      expect(page).to have_content('PaymentJob')
      expect(page).to have_content('ClosedLoop')
      expect(page).to have_content('Eml')
    end
  end
end
