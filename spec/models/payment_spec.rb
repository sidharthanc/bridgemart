describe Payment, type: :model do
  subject { described_class.new }
  let(:order) { orders(:metova_credit) }
  before do
    order.payment_method.update(organization: order.organization)
  end

  context '#find_payment_method' do
    it 'returns an existing payment method' do
      subject.billing_id = order.payment_method.billing_id
      expect(subject.send(:find_payment_method, order)).to eq order.payment_method
    end

    it 'returns a new payment method' do
      subject.billing_id = nil
      expect(subject.send(:find_payment_method, order)).not_to be_persisted
    end

    it 'returns a new payment method where billing_id is blank, not nil' do
      subject.billing_id = ''
      order.payment_method.update billing_id: ''
      expect(subject.send(:find_payment_method, order)).not_to be_persisted
    end
  end
end
