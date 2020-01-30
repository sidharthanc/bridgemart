describe ClosedLoop::Transactions::ActivatePhysicalCard do
  subject { described_class.new(id: 42, card_number: "5555123412341234", ean: "XXXX", amount: 500, organization_id: 998) }
  it { expect(subject.request.transaction).to eq :activate_physical_card }
  it 'includes all the required fields' do
    expect(subject.request.included_codes).to include('12', '13', '42', '70', 'EA')
  end

  context 'with encryption enabled' do
    before { stub_const('ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION', true) }
    it 'includes all the required fields' do
      expect(subject.request.included_codes).to include('12', '13', '42', '70', 'EA', 'F3')
    end
  end

  describe '.perform' do
    before do
      allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/activate')
      expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/activate_physical_card_success.xml'))
    end

    it { expect(subject.perform).to be_success }
  end
end
