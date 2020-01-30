describe 'Password Reset', type: :request do
  let(:user) { users(:joseph) }

  before do
    visit new_user_password_path
  end

  it 'shows the login page when not logged in' do
    expect(page).to have_field 'user[email]'
  end

  it 'sends a password reset email when an email is entered' do
    fill_in 'user_email', with: user.email
    expect do
      click_button I18n.t('devise.passwords.new.reset_submit')
    end.to change(Notification, :count).by 1
  end
end
