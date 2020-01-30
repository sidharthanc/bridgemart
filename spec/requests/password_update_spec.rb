describe 'Password Update', type: :request do
  let(:user) { users(:joseph) }

  before do
    allow(Devise).to receive(:friendly_token).and_return('abcdef')
  end

  it 'shows the login page when not logged in' do
    visit edit_user_password_path(reset_password_token: 'abcdef')
    expect(page).to have_field 'user[password]'
    expect(page).to have_field 'user[password_confirmation]'
  end

  it 'updates user password' do
    visit new_user_password_path

    fill_in 'user[email]', with: user.email

    click_button I18n.t('devise.passwords.new.reset_submit')

    visit edit_user_password_path(reset_password_token: 'abcdef')

    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'password'

    click_button I18n.t('devise.passwords.edit.edit_password_confirm')

    expect(page).to have_content I18n.t('devise.passwords.updated')
    expect(user.reload.valid_password?('password')).to be true
  end
end
