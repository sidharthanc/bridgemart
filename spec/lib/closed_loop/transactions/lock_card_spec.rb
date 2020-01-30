describe ClosedLoop::Transactions::LockCard do
  subject { described_class.new(card_number: 42, ean: "XXX") }
  before { allow(FirstData::Client).to receive(:service_url).and_return("https://staging2.datawire.net/sd") }
  it { expect(subject.request.transaction).to eq :freeze_active_card }
  it 'includes all required fields' do
    expect(subject.request.included_codes).to include('12', '13', '42', '70', 'EA')
  end
  context 'unlock' do
    subject { described_class.new(card_number: 42, ean: "XXX", action: :unlock) }
    it { expect(subject.request.transaction).to eq :unfreeze_active_card }
    it 'includes all required fields' do
      expect(subject.request.included_codes).to include('12', '13', '42', '70', 'EA')
    end
  end

  describe 'perform' do
    context 'lock', vcr: { cassette_name: 'closed_loop/lock-card' } do
      let!(:card) do
        ClosedLoop::Transactions::ActivateCard.new(id: 998, limit: 800, organization_id: 1).perform.try(:fields)
      end
      subject { described_class.new(card_number: card[:embossed_card_number], ean: card[:extended_account_number]).try(:perform) }
      it { is_expected.to be_success }
    end
    context 'unlock', vcr: { cassette_name: 'closed_loop/unlock-card' } do
      let!(:card) do
        fields = ClosedLoop::Transactions::ActivateCard.new(id: 32, limit: 1200, organization_id: 1).perform.try(:fields)
        described_class.new(card_number: fields[:embossed_card_number], ean: fields[:extended_account_number]).try(:perform)
        fields
      end
      subject { described_class.new(card_number: card[:embossed_card_number], ean: card[:extended_account_number], action: :unlock).try(:perform) }
      it { is_expected.to be_success }
    end
  end
end
