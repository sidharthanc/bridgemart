describe ClosedLoop::Request do
  subject { described_class.new(transaction: :activate_virtual_card) }
  before do
    allow(FirstData::Client).to receive(:credentials).and_return(mid: "_MID_", service_discovery_urls: ['https://example.com/'])
  end

  describe '.header' do
    it 'concatinates the header into a single string with field separator' do
      expect(subject.header).to eq 'SV._MID_|1C402102'
    end
  end

  describe '.build_field' do
    it 'uses the value given if no lambda configured' do
      field = subject.build_field(:reference_number, '32324242')
      expect(field).to eq %w[08 32324242]
    end
    it 'calls the configured lambda if present' do
      field = subject.build_field(:merchant_id)
      expect(field).to eq %w[11 _MID_]
    end
    it 'passed values are curried to the default lambda' do
      today = Date.current
      field = subject.build_field(:expiration_date, today)
      expect(field).to eq ['A0', today.strftime('%m%d%Y')]
    end
  end
  describe 'add_field' do
    it 'appends the field to fields, passing arguents down to build_field' do
      field = subject.build_field(:reference_number, '32324242')

      subject.add_field(:reference_number, '32324242')
      expect(subject.fields).to include(field)
    end
  end

  describe 'included_fields' do
    before do
      subject.add_field(:reference_number, '32324242')
      subject.add_field(:merchant_id)
    end
    it { expect(subject.included_codes).to eq %w[08 11] }
  end

  describe '.to_payload' do
    subject do
      described_class.new(transaction: :activate_virtual_card) do |request|
        request.add_field(:merchant_id)
        request.add_field(:reference_number, '32324242')
        request.add_field(:echo, "YAHUUGA")
      end
    end
    it 'concatinates the header and all fields into a single string' do
      expect(subject.to_payload).to eq 'SV._MID_|1C402102|1C11_MID_|1C0832324242|1C7FYAHUUGA'
    end
  end

  describe 'TOR .to_payload' do
    let(:transaction) do
      ClosedLoop::Request.new(transaction: :activate_virtual_card) do |request|
        request.add_field(:merchant_id)
        request.add_field(:reference_number, '32324242')
        request.add_field(:echo, "YAHUUGA")
      end
    end

    it 'concatinates the header and all fields into a single string during TOR' do
      expect(transaction.build_reversal_payload.to_payload).to eq 'SV._MID_|1C400704|1C11_MID_|1C0832324242|1C7FYAHUUGA|1CF62102'
    end
  end

  describe '.perform' do
    context 'with required fields' do
      before do
        expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/activate_card_success.xml'))
      end
      subject do
        described_class.new(transaction: :activate_virtual_card) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:source_code)
          request.add_field(:promotion_code)
        end.perform
      end

      it { is_expected.to be_a ClosedLoop::Response }
      it { expect { subject }.to change(ServiceActivity, :count).by(1) }
    end

    context 'missing required fields' do
      subject do
        described_class.new(transaction: :activate_virtual_card) do |request|
          request.add_field(:merchant_id)
        end.perform
      end
      it { expect { subject.perform }.to raise_error(ClosedLoop::Request::MissingRequiredField) }
    end

    context 'with required fields, but timed out' do
      before do
        allow_any_instance_of(FirstData::Request).to receive(:perform) { raise Faraday::TimeoutError }
      end

      subject do
        described_class.new(transaction: :activate_virtual_card) do |request|
          request.add_field(:transaction_time)
          request.add_field(:transaction_date)
          request.add_field(:merchant_and_terminal_id)
          request.add_field(:source_code)
          request.add_field(:promotion_code)
        end
      end

      it 'transmits a timeout reversal (TOR) request' do
        allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/service')
        expect(subject).to receive(:transmit_timeout_reversal)
        expect { subject.perform }.to raise_error Faraday::TimeoutError
      end
    end

    context 'DataWire Okay, but 205 (Timeout) Response Code' do
      before do
        expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/datawire_success_with_205_timeout.xml'))
      end

      subject do
        described_class.new
      end

      it 'transmits a timeout reversal (TOR) request' do
        expect(subject).to receive(:transmit_timeout_reversal)
        expect { subject.perform(validate: false) }.to raise_error Faraday::TimeoutError
      end
    end
  end
end
