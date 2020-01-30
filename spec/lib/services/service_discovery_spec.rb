describe FirstData::Services::ServiceDiscovery do
  let(:service_discovery_urls) { ['https://first.data/service_discovery'] }
  let(:response) { file_fixture('first_data/service_discovery_response.xml').read }
  before do
    allow(FirstData::Client).to receive(:credentials).and_return(
      {}.tap do |c|
        c[:user_agent] = 'USER_AGENT'
        c[:service_discovery_urls] = service_discovery_urls
      end
    )
    stub_request(:get, service_discovery_urls.first)
      .with(
        headers: {
          'Connection' => 'Keep-Alive',
          'Cache-Control' => 'no-cache',
          'Content-Type' => 'text/xml',
          'User-Agent' => 'USER_AGENT'
        }
      )
      .to_return(status: 200, body: response, headers: {})
  end
  describe '.all_service_discovery_urls' do
    subject { described_class.all_service_discovery_urls }
    it { is_expected.to eq service_discovery_urls }
  end
  describe '.service_discovery_url' do
    subject { described_class.service_discovery_url }
    it { is_expected.to eq service_discovery_urls.first }
  end

  describe '#discover' do
    subject { described_class.new.send(:discover, url: described_class.service_discovery_url) }
    it {
      is_expected.to eq ["https://staging1.datawire.net/sd",
                         "https://staging2.datawire.net/sd",
                         "https://staging3.datawire.net/sd"]
    }
  end
  describe 'perform' do
    subject { described_class.new.perform }
    it {
      is_expected.to eq ["https://staging1.datawire.net/sd",
                         "https://staging2.datawire.net/sd",
                         "https://staging3.datawire.net/sd"]
    }
  end
end
