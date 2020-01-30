describe Plan, type: :model do
  subject { plans(:metova) }

  it { is_expected.to have_many(:plan_product_categories) }
  it { is_expected.to have_many(:product_categories) }
  it { is_expected.to have_many(:orders) }
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to be_auditable }

  describe '#active?' do
    let(:order) { subject.orders.last }

    it 'returns false if the latest order for plan starts in the future' do
      order.update starts_on: 1.week.from_now
      order.update ends_on: 1.year.from_now
      expect(subject).to_not be_active
    end

    it 'returns true if the latest order for plan is ongoing' do
      order.update starts_on: Date.current
      order.update ends_on: Date.current + 1.year
      expect(subject).to be_active
    end
  end
end
