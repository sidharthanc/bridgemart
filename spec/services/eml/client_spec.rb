describe EML::Client do
  subject do
    Class.new { extend EML::Client }
  end

  describe 'credential handling' do
    # The way this is currently set up with constants won't allow me to test this properly
    # TODO: Needs refactor
    # context 'production with USE_STAGING_SERVICE_IN_PRODUCTION false' do
    #   before do
    #     stub_const('EML::Client::USE_STAGING_SERVICE_IN_PRODUCTION', false)
    #     stub_const('EML::Client::CREDENTIAL_ENV', :production)
    #     allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    #   end
    #   it { expect(EML::Client::CREDENTIALS[:eml]).to eq Rails.application.credentials.dig(:production, :eml) }
    # end
    context 'allowing staging credentials in production' do
      before do
        stub_const('EML::Client::USE_STAGING_SERVICE_IN_PRODUCTION', true)
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end
      it { expect(EML::Client::CREDENTIALS[:eml]).to eq Rails.application.credentials.dig(:staging, :eml) }
    end
  end

  describe '#post' do
    it 'sets the merchant group' do
      webmock :post, /test/ => 'blank.json'
      subject.post 'test'
      expect(WebMock).to have_requested(:post, /test/).with body: hash_including(merchant_group: EML::Client::MERCHANT_GROUP)
    end

    it 'sets the program' do
      webmock :post, /test/ => 'blank.json'
      subject.post 'test'
      expect(WebMock).to have_requested(:post, /test/).with body: hash_including(program: EML::Client::PROGRAM)
    end

    it 'uses the ExternalId search parameter' do
      webmock :post, /test/ => 'blank.json'
      subject.post 'test'
      expect(WebMock).to have_requested(:post, /test/).with query: hash_including(search_parameter: 'ExternalId')
    end

    it 'raises an exception if the API fails' do
      expect do
        webmock :post, /test/ => 'eml/error.500.json'
        subject.post 'test'
      end.to raise_error(EML::Error, 'Test error')
    end
    it 'creates service activity' do
      expect do
        webmock :post, /test/ => 'eml/error.500.json'
        subject.post 'test'
      end.to raise_error(EML::Error, 'Test error').and change(ServiceActivity, :count)
    end
  end
end
