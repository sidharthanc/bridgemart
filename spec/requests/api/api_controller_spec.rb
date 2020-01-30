RSpec.describe API::BaseController, type: :request do
  let(:organization) { create(:organization) }
  describe 'token authentication' do
    context 'unauthenticated' do
      it 'returns not authorized' do
        get '/api/verify', params: {}, headers: { 'API_KEY' => 'not-gonna-work' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'returns OK if authenticated' do
      get '/api/verify', params: {}, headers: { 'API_KEY' => organization.authentication_token }
      expect(response).to be_successful
      expect(response.body).to eql 'OK'
    end
  end
  describe 'database / sessioncookie authentication' do
    context 'unauthenticated' do
      it 'returns not authorized' do
        get '/api/verify'
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'unauthenticated' do
      before { sign_in organization.primary_user }
      it 'returns OK' do
        get '/api/verify'
        expect(response).to be_successful
        expect(response.body).to eql 'OK'
      end
    end
  end
end
