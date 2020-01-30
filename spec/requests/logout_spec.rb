describe 'User logout', type: :request do
  as { users(:joseph) }

  it 'logs the user out' do
    visit root_path
    click_on t('layouts.dashboard.sign_out')
    expect(current_path).to eq new_user_session_path
  end
end
