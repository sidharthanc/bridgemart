describe ClosedLoop::Transactions::VoidActivateCard do
  subject { described_class.new(card_number: "7777165452298382", ean: "XXXX", amount: 35) }
  it { expect(subject.request.transaction).to eq :void_activation }
  it 'includes all the required fields' do
    expect(subject.request.included_codes).to include('04', '12', '13', '70', '42', 'EA')
  end

  describe '.perform' do
    before do
      allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/activate')
      expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/void_activate_card_success.xml'))
    end

    it { expect(subject.perform).to be_success }
  end
end
