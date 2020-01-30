describe ClosedLoop::Transactions::TransactionHistory do
  subject { described_class.new(card_number: "7777165452372555", ean: "XXXX") }

  it { expect(subject.request.transaction).to eq :transaction_history }

  it 'includes all required fields' do
    expect(subject.request.included_codes).to include('12', '13', '70', '42', 'EA', 'E8')
  end

  describe 'perform' do
    before do
      expect(FirstData::Request).to receive_message_chain(:new, perform: first_data_response('closed_loop/transaction_history_inquiry_success.xml'))
    end

    it { expect(subject.perform).to be_success }
    it { expect(subject.perform.fields[:transaction_history_detail]).to include("|22t|28H|20|20u|7Eu|7E5|22|2B|20|20|20|20J|20|20|20|20|20J|20|20|20|20|20|20|20|2C2425|5B") }
  end
end
