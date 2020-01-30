describe 'User login', type: :request do
  let(:user) { users(:joseph) }

  before do
    visit new_user_session_path
  end

  it 'has a link to the sign up page' do
    expect(page).to have_link I18n.t('shared.header.nav.sign_up')
  end

  context 'valid credentials' do
    it 'shows the login page when not logged in' do
      expect(page).to have_field 'user[email]'
      expect(page).to have_field 'user[password]'
    end

    it 'allows the user to login' do
      login user
      expect(page).to have_link I18n.t('layouts.dashboard.sign_out'), href: destroy_user_session_path
      expect(current_path).to eq authenticated_root_path
    end

    it 'shows a successful message after logging in' do
      login user
      expect(page).to have_css '.alert-notice'
      expect(page).to have_content 'Signed in successfully.'
    end
  end

  context 'invalid credentials' do
    it 'does not log the user in' do
      login user, 'incorrect'
      expect(page).to_not have_link 'Logout'
      expect(current_path).to eq new_user_session_path
    end

    it 'shows a failure message when failing to login' do
      login user, 'incorrect'
      expect(current_path).to eq new_user_session_path
      expect(page).to_not have_content 'Signed in successfully.'
      expect(page).to have_css '.alert-alert'
    end
  end

  context 'signing in as broker' do
    let(:broker) { users(:broker) }

    before { broker.organizations = Organization.all }

    it 'directs user to overview page' do
      visit root_path
      login broker
      expect(current_path).to eq(organizations_path)
    end
  end

  def login(user, password = 'password')
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: password
    find('input[type=submit]').click
  end
end
