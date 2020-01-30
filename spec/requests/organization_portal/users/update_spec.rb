describe 'Editing a user', type: :request do
  let(:form) { UserForm.new }
  let(:user_one) { users(:test_three) }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  before do
    sign_in user
  end

  context 'as an admin' do
    it 'edits a user under the current organization' do
      visit edit_organization_user_path(organization, user_one)

      fill_in 'user[first_name]', with: 'Edited'
      fill_in 'user[last_name]', with: 'Name'
      expect(page).to have_css('.check_boxes.user_permission_groups')

      expect do
        form.submit
      end.to change(organizations(:metova).users, :count).by 0

      expect(page.current_path).to eq organization_users_path(organization)
      expect(user_one.reload.first_name).to eq('Edited')
      expect(user_one.reload.last_name).to eq('Name')
    end

    it 'masks the phone number input', js: true do
      visit edit_organization_user_path(organization, user_one)
      fill_in "user[phone_number]", with: '99999999999'
      expect do
        form.submit
        expect(page.current_path).to eq organization_users_path(organization)
      end.to change(organizations(:metova).users, :count).by 0
      expect(user_one.reload.phone_number).to eq '(999) 999-9999'
    end

    it 'shows validation errors if invalid' do
      visit edit_organization_user_path(organization, user_one)

      fill_in 'user[first_name]', with: ''

      expect do
        form.submit
        expect(page).to have_content "First name can't be blank"
      end.to_not change(organizations(:metova).users, :count)
    end

    context 'with assignable permission groups' do
      it 'cannot assign a permission group to their self' do
        visit edit_organization_user_path(organization, user)

        expect(page).to have_no_css('.check_boxes.user_permission_groups')
      end
    end
  end

  context 'with assignable permission groups' do
    before { user.permission_groups += [permission_groups(:none)] }

    it 'should be able to assign a permission group' do
      visit edit_organization_user_path(organization, user_one)
      check permission_groups(:none).name
      form.submit
      visit organization_user_path(organization, user_one)
      expect(page).to have_content permission_groups(:none).name
      expect(page).to have_no_content permission_groups(:organization).name
    end
  end

  context 'as a non-admin user' do
    it 'redirects the non-admin user to the root path' do
      visit admin_dashboard_path
      expect(page).to have_current_path root_path
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end
end
