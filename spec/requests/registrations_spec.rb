describe 'Registration', type: :request do
  context 'editing user registration' do
    let(:user) { users(:joseph) }

    before do
      user.update password: 'other_password'
      sign_in user
      visit edit_user_registration_path
    end

    it 'displays the registration edit form' do
      expect(page).to have_field 'user[password]'
      expect(page).to have_field 'user[password_confirmation]'
      expect(page).to have_field 'user[current_password]'
    end

    it 'updates a users password' do
      fill_in 'user[password]', with: 'password'
      fill_in 'user[password_confirmation]', with: 'password'
      fill_in 'user[current_password]', with: 'other_password'
      find('input[type=submit]').click

      expect(page).to have_content I18n.t('devise.registrations.updated')
      expect(user.reload.valid_password?('password')).to be true
    end
  end
end
