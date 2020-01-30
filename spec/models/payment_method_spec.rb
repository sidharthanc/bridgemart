RSpec.describe PaymentMethod, type: :model do
  let(:card) { payment_methods(:credit) }
  let(:ach) { payment_methods(:ach) }

  it { is_expected.to belong_to(:organization) }

  describe '#payment_type' do
    it 'returns :credit when a credit card is present' do
      expect(card.payment_type).to equal :credit
    end

    it 'returns :ach when an ach account number is present' do
      expect(ach.payment_type).to equal :ach
    end

    it 'returns nil when no cc or ach number is present' do
      expect(described_class.new.payment_type).to equal nil
    end
  end
end
