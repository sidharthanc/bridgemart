describe FirstData::Request do
  before { allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/service') }
  subject { described_class.new(service: 'SomeService', service_id: '999') }

  it { is_expected.to have_attributes(service: 'SomeService', method: :post) }
  it { expect(subject.connection).to be_a Faraday::Connection }
  it { expect(subject.body).to be_present }
  it { expect(subject.body).to be_a String }
  it { expect(subject.body).to include('<SomeService><ServiceID>999</ServiceID></SomeService>') }

  describe 'perform' do
    it do
      freeze_time do
        client_reference = subject.send(:client_reference)
        body = '<?xml version="1.0" encoding="UTF-8"?><Request Version="3"><ReqClientID><DID>00033746370969070150</DID><App>BRIDGEPINCVLKXML</App><Auth>99026809996|00000008594</Auth><ClientRef>GSUBCLIENTREF</ClientRef></ReqClientID><SomeService><ServiceID>999</ServiceID></SomeService></Request>'
        body.gsub!(/GSUBCLIENTREF/, client_reference)

        stub_request(:post, "https://first.data/service")
          .with(body: body)
          .to_return(status: 200, body: file_fixture('first_data/generic_response.xml'))
        subject.perform
      end
    end
  end
end
