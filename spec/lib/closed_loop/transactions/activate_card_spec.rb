describe ClosedLoop::Transactions::ActivateCard do
  subject { described_class.new(id: 42, limit: amount, organization_id: 1) }
  let(:amount) { 50.to_money }
  before { allow(FirstData::Client).to receive(:service_url).and_return("https://staging2.datawire.net/sd") }
  it { expect(subject.request.transaction).to eq :activate_virtual_card }
  it 'includes all the required fields' do
    expect(subject.request.included_codes).to include('12', '13', '42', 'EA', 'F2')
  end
  context 'with encryption enabled' do
    before { stub_const('ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION', true) }
    it 'includes all the required fields' do
      expect(subject.request.included_codes).to include('12', '13', '42', 'EA', 'F2', 'F3')
    end
  end

  describe '.perform', vcr: { cassette_name: 'closed_loop/activate-card' } do
    it { expect(subject.perform).to be_success }
    it { expect(subject.perform.try(:fields)).to include(:embossed_card_number, :extended_account_number, :new_balance) }
    it 'has legit/valid fields' do
      card = subject.perform.try(:fields)
      expect(card[:new_balance]).to eq "5000"
      expect(card[:embossed_card_number]).to be_present
      expect(card[:extended_account_number]).to be_present
    end
  end
end
