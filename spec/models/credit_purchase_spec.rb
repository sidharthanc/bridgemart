describe CreditPurchase, type: :model do
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to belong_to(:payment_method) }

  it { is_expected.to have_many(:credits) }

  it { is_expected.to allow_value(1.to_money).for(:amount) }
  it { is_expected.not_to allow_value(0.to_money).for(:amount) }
  it { is_expected.not_to allow_value(-1.to_money).for(:amount) }

  it { is_expected.to be_auditable }

  context '#paid?' do
    it 'is false when not paid' do
      expect(subject.paid?).to be_falsey
    end

    it 'is true when paid' do
      subject.paid!
      expect(subject.paid?).to be_truthy
    end
  end

  context '#void!' do
    before do
      subject.organization = organizations(:metova)
      subject.payment_method = payment_methods(:ach)
      subject.amount = 200
    end

    it 'allows the unpaid credit purchase to be voided' do
      expect { subject.void! }.to change(subject, :voided_at).from(nil)
    end

    it 'disallows the paid credit purchase to be voided' do
      subject.paid!

      expect { subject.void! }.not_to change(CreditPurchase.find(subject.id), :voided_at)
      expect(subject.errors.details[:voided_at]).to include error: :cannot_void
    end
  end

  describe '#to_csv' do
    it 'returns a csv for a collection of credit purchases' do
      csv = described_class.all.to_csv

      described_class.all.each do |credit_purchase|
        record = [
          credit_purchase.paid_at,
          credit_purchase.voided_at,
          credit_purchase.po_number,
          credit_purchase.error_message,
          credit_purchase.processing,
          credit_purchase.amount,
          credit_purchase.amount_currency,
          credit_purchase.organization_id,
          credit_purchase.payment_method_id,
          credit_purchase.created_at,
          credit_purchase.updated_at
        ].join(',')

        expect(csv).to include record
        expect(csv).not_to match /translation missing/
      end
    end
  end
end
