describe 'Home', type: :request do
  before { visit '/' }

  it 'is the login page' do
    expect(page).to have_content I18n.t('devise.sessions.new.login_welcome')
  end
end
