describe ClosedLoop::Transactions::BalanceInquiry do
  subject { described_class.new(card_number: "7777165452269723", ean: "XXXX") }
  before { allow(FirstData::Client).to receive(:service_url).and_return("https://staging2.datawire.net/sd") }
  it { expect(subject.request.transaction).to eq :balance }
  it 'includes all required fields' do
    expect(subject.request.included_codes).to include('12', '13', '70', '42', 'EA')
  end

  describe 'perform', vcr: { cassette_name: 'closed_loop/balance-inquiry' } do
    let(:amount) { 15.30.to_money }
    let!(:card) do
      ClosedLoop::Transactions::ActivateCard.new(id: 99, limit: amount, organization_id: 1).perform.try(:fields)
    end
    subject { described_class.new(card_number: card[:embossed_card_number], ean: card[:extended_account_number]) }

    it { expect(subject.perform).to be_success }
    it { expect(subject.perform.fields[:new_balance]).to eq '1530' }
  end
end
