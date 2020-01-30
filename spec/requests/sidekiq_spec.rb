describe 'Sidekiq API route', type: :request do
  context '/sidekiq API access' do
    it 'disallows access to everyone' do
      visit sidekiq_web_path
      expect(current_path).to eq new_user_session_path
    end

    it 'disallows access to normal users' do
      sign_in users(:test_three)
      expect { visit sidekiq_web_path }.to raise_error ActionController::RoutingError
    end

    it 'allows access to admin users' do
      sign_in users(:andrew)
      visit sidekiq_web_path

      expect(page.status_code).to eq 200
    end
  end
end
