describe ClosedLoop::Transactions::CloseCard do
  subject { described_class.new(card_number: 42, ean: "XXX") }
  before { allow(FirstData::Client).to receive(:service_url).and_return("https://staging2.datawire.net/sd") }
  it { expect(subject.request.transaction).to eq :close_account }
  it 'includes all required fields' do
    expect(subject.request.included_codes).to include('12', '13', '42', '70', 'EA', 'FA')
  end

  describe 'perform', vcr: { cassette_name: 'closed_loop/close-card' } do
    let!(:card) do
      ClosedLoop::Transactions::ActivateCard.new(id: 42, limit: 4200, organization_id: 1).perform.try(:fields)
    end
    subject { described_class.new(card_number: card[:embossed_card_number], ean: card[:extended_account_number]).try(:perform) }
    it { expect(subject).to be_success }
    it 'balances are correct' do
      expect(subject.fields[:previous_balance]).to eq '4200'
      expect(subject.fields[:new_balance]).to eq '0'
    end
  end
end
