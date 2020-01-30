describe ClosedLoop::Transactions::ReloadCard do
  before do
    allow(FirstData::Client).to receive(:service_url).and_return('https://first.data/activate')
  end
  subject { described_class.new(card_number: 42, ean: "XXX", amount: 5000) }
  it { expect(subject.request.transaction).to eq :reload }
  it 'includes all required fields' do
    expect(subject.request.included_codes).to include('04', '12', '13', '70', '42', 'EA')
  end

  describe 'perform' do
    before do
      expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/close_card_success.xml'))
    end
    it { expect(subject.perform).to be_success }
  end
end
