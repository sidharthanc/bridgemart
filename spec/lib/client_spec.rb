describe FirstData::Client do
  subject { described_class }
  describe '#credentials' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    end
    it { expect(subject.credentials).to eq Rails.application.credentials.dig(:production, :first_data) }
    context 'allowing staging credentials in production' do
      before do
        FirstData.setup do |config|
          config.credential_environment = :staging
        end
      end
      it { expect(subject.credentials).to eq Rails.application.credentials.dig(:staging, :first_data) }
    end
  end

  describe '#service_url' do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }
    let(:urls) { %w[url1 url2 url3] }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)

      allow(FirstData::Services::ServiceDiscovery).to receive(:new).and_return(double(perform: urls))
      expect(FirstData::Services::Ping).to receive(:new).with('url1')
                                                        .and_return(double(perform: 2.3))
      expect(FirstData::Services::Ping).to receive(:new).with('url2')
                                                        .and_return(double(perform: 0.9))
      expect(FirstData::Services::Ping).to receive(:new).with('url3')
                                                        .and_return(double(perform: nil))
    end
    subject { described_class.service_url }
    context 'when a url gets reset' do
      before do
        described_class.service_url # 'discover' first url, this should be url2
        described_class.reset_service_url!
      end
      it 'should return next url in list and not rediscover' do
        expect(FirstData::Services::ServiceDiscovery).not_to receive(:new)
        expect(FirstData::Services::Ping).not_to receive(:new)
        is_expected.to eq 'url1'
      end
      it 'should not include url3 in hosts' do
        expect(described_class.ranked_hosts).not_to include ['url3', Float::INFINITY]
      end
      context 'no more service urls' do
        before { 2.times { described_class.reset_service_url! } }
        it 'should re-discover' do
          is_expected.to eq 'url1'
        end
      end
    end
  end

  describe '#connection' do
    before do
      allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/endpoint')
    end
    subject { described_class.connection }
    it { is_expected.to be_a Faraday::Connection }
    it { expect(subject.url_prefix.to_s).to eq 'https://first.data/endpoint' }

    context 'custom url' do
      let(:url) { 'https://some.host.tld/path/way' }
      subject { described_class.connection(url) }

      it { is_expected.to be_a Faraday::Connection }
      it { expect(subject.url_prefix.to_s).to eq url }
    end
  end
end
