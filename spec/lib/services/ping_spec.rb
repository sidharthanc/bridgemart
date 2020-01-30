describe FirstData::Services::Ping do
  before do
    allow_any_instance_of(described_class).to receive(:client_reference) { 'MID' }

    allow(FirstData::Client).to receive(:credentials).and_return(
      {}.tap do |c|
        c[:user_agent] = 'USER_AGENT'
        c[:app] = 'APP'
        c[:did] = 'DID'
        c[:mid] = 'MID'
        c[:tid] = 'TID'
      end
    )
    stub_request(:post, url)
      .with(
        body: '<?xml version="1.0" encoding="UTF-8"?><Request Version="3"><ReqClientID><DID>DID</DID><App>APP</App><Auth>MID|TID</Auth><ClientRef>MID</ClientRef></ReqClientID><Ping><ServiceID>104</ServiceID></Ping></Request>',
        headers: {
          'Connection' => 'Keep-Alive',
          'Cache-Control' => 'no-cache',
          'Content-Type' => 'text/xml',
          'User-Agent' => 'USER_AGENT'
        }
      )
      .to_return(status: 200, body: file_fixture('first_data/ping_service_response.xml'), headers: {})
  end
  let(:response) { file_fixture('first_data/ping_service_response.xml').read }
  let(:url) { 'https://first.data/path/to/endpoint' }
  subject { described_class.new(url) }

  it { is_expected.to be_a FirstData::Request }

  describe '.perform' do
    subject { described_class.new(url).perform }

    it { is_expected.to be_a Float }
  end
end
