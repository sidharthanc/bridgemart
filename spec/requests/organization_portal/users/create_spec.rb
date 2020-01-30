describe 'Adding a user', type: :request do
  let(:form) { UserForm.new }
  let(:admin_group) { permission_groups(:admin) }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  before do
    sign_in user
  end

  context 'admin user' do
    before do
      user.permission_groups = [admin_group]
    end

    it 'creates a new user under the current organization' do
      visit new_organization_user_path(organization)
      form.fill
      expect do
        form.submit
        expect(page.current_path).to eq organization_users_path(organization)
      end.to change(organizations(:metova).users, :count).by 1
    end

    it 'masks the phone number input', js: true do
      visit new_organization_user_path(organization)
      form.fill
      fill_in "user[phone_number]", with: '1234567890'
      expect do
        form.submit
        expect(page.current_path).to eq organization_users_path(organization)
      end.to change(organizations(:metova).users, :count).by 1
      expect(organization.users.find_by(email: form.email).phone_number).to eq '(123) 456-7890'
    end

    it 'fires off the email to the new user' do
      visit new_organization_user_path(organization)
      form.fill
      expect do
        form.submit
      end.to have_enqueued_job.on_queue('mailers')
    end

    it 'shows validation errors if invalid' do
      visit new_organization_user_path(organization)
      form.fill
      fill_in 'user[first_name]', with: ''
      expect do
        form.submit
        expect(page).to have_content "First name can't be blank"
      end.to_not change(organizations(:metova).users, :count)
    end
  end

  context 'non-admin user' do
    it 'redirects the non-admin user to the root path' do
      visit admin_dashboard_path
      expect(page).to have_current_path root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
