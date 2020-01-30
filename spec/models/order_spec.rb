describe Order, type: :model do
  subject { orders(:metova) }
  let(:other_order) { orders(:bridge) }
  let(:date_string) { '06/22/2018' }
  let(:date_real) { Date.new(2018, 6, 22) }
  let(:unpaid_order) { orders(:metova_unpaid) }

  it { is_expected.to belong_to(:plan) }
  it { is_expected.to belong_to(:payment_method) }
  it { is_expected.to have_one(:organization) }
  it { is_expected.to have_many(:members) }
  it { is_expected.to have_many(:plan_product_categories) }
  it { is_expected.to have_many(:product_categories) }
  it { is_expected.to have_many(:redemption_instructions) }
  it { is_expected.to be_auditable }
  it { is_expected.to have_and_belong_to_many(:special_offers) }
  it { is_expected.to have_db_column(:uuid) }

  before do
    Member.counter_culture_fix_counts # required due to fixtures vs factories skips hooks
  end

  describe 'cached counters' do
    it 'member count' do
      expect(subject.members_count).to eq 3 # magic factory
      subject.members.last.destroy
      subject.reload
      expect(subject.members_count).to eq 2
    end
  end
  describe 'starts_on / ends_on' do
    subject { build(:order) }
    it { is_expected.to allow_values(Date.current, Date.current + 30.days).for(:starts_on) }
    it { is_expected.to_not allow_values(Date.current - 1.days, Date.current + 45.days).for(:starts_on) }

    context 'with starts on set' do
      subject { build(:order, starts_on: Date.current) }
      it { is_expected.to allow_values(Date.current + 1.day, Date.current + 300.days).for(:ends_on) }
      it { is_expected.to_not allow_values(subject.starts_on - 1.day, subject.starts_on + 1.year + 1.day).for(:ends_on) }
    end
  end

  describe 'legacy_identifier' do
    it 'restrict unique legacy_identifiers values' do
      subject.update_attribute(:legacy_identifier, 12_345)
      expect { other_order.update_attribute(:legacy_identifier, 12_345) }.to raise_error ActiveRecord::RecordNotUnique
    end

    it 'allow multiple nil legacy_identifier values' do
      subject.update_attribute(:legacy_identifier, nil)
      expect { other_order.update_attribute(:legacy_identifier, nil) }.not_to raise_error
    end
  end

  describe '#legacy?' do
    it 'returns false on orders originated on this app' do
      expect(subject).not_to be_legacy
    end

    it 'returns true on imported orders' do
      subject.legacy_identifier = 'foobar'
      expect(subject).to be_legacy
    end
  end

  describe '#charges' do
    it 'returns the correct number of elements' do
      expect(subject.charges.count).to eq plan_product_categories.count
      expect(subject.charges.first).to be_an_instance_of Charge
    end

    it 'returns the correct number of elements on legacy order' do
      subject.update legacy_identifier: 123_456
      subject.line_items << LineItem.new(order: subject, charge_type: :charge, amount: 1200.to_money, quantity: 4)
      expect(subject.charges.first.price).to eq 1200.to_money
      expect(subject.charges.count).to eq subject.line_items.charges.count
      expect(subject.charges.first).to be_an_instance_of Charge
    end
  end

  describe '#fees' do
    it 'returns the correct number of elements' do
      expect(subject.fees.count).to eq plan_product_categories.count
      expect(subject.fees.first).to be_an_instance_of Charge
    end

    it 'returns the correct number of elements on legacy order' do
      subject.update legacy_identifier: 123_456
      subject.line_items << LineItem.new(order: subject, charge_type: :fee, amount: 108.to_money, quantity: 4)
      expect(subject.fees.first.price).to eq 108.to_money
      expect(subject.fees.count).to eq subject.line_items.fees.count
      expect(subject.fees.first).to be_an_instance_of Charge
    end
  end

  describe '#credits' do
    before { subject.line_items.create(source: subject.organization, charge_type: :credit, amount: 1, description: t('orders.credits_applied_from', source_name: subject.organization.name)) }

    it 'returns the credit line items' do
      expect(subject.line_items.count).to eq 1
      expect(subject.line_items.first).to be_an_instance_of LineItem
    end
  end

  describe '#total' do
    it 'returns the charges, formatted' do
      expect(subject.total).to be_an_instance_of Money
      expect(subject.total.format).to eq '$975.00'
    end
  end

  describe '#total_with_credits' do
    before { subject.line_items.create(source: subject.organization, charge_type: :credit, amount: subject.total.to_i, description: t('orders.credits_applied_from', source_name: subject.organization.name)) }

    it 'returns the charges after credits have been deducted, formatted' do
      expect(subject.total_with_credits).to be_an_instance_of Money
      expect(subject.total_with_credits.format).to eq '$0.00'
    end
  end

  describe '#total_credits' do
    before { subject.line_items.create(source: subject.organization, charge_type: :credit, amount: subject.total.to_i, description: t('orders.credits_applied_from', source_name: subject.organization.name)) }

    it 'returns the amount of credits that will be deducted, formatted' do
      expect(subject.total_credits).to be_an_instance_of Money
      expect(subject.total_credits.format).to eq subject.total.format
    end
  end

  describe '#total_charges' do
    it 'returns the charges, formatted' do
      expect(subject.total_charges).to be_an_instance_of Money
      expect(subject.total_charges.format).to eq '$885.00'
    end
  end

  describe '#total_fees' do
    it 'returns the fee charges, formatted' do
      expect(subject.total_fees).to be_an_instance_of Money
      expect(subject.total_fees.format).to eq '$90.00'
    end
  end

  describe '#balance_due' do
    it 'returns zero if the balance is paid' do
      expect(subject.balance_due).to be_an_instance_of Money
      expect(subject.balance_due.format).to eq '$0.00'
    end

    it 'returns the total if the balance is not paid' do
      allow(subject).to receive(:has_no_due?).and_return(false)
      expect(subject.balance_due).to be_an_instance_of Money
      expect(subject.balance_due.format).to eq '$975.00'
    end
  end

  describe '#members_count' do
    it 'returns the number of associated members' do
      expect(subject.members_count).to eq subject.members.count
    end
  end

  describe '#deduct_credits' do
    before { subject.organization.credits.create(source: subject.organization, amount: subject.total.to_i) }

    it 'creates credit line_items for an order' do
      expect { subject.reload.deduct_credits(subject.total.to_i) }.to change(LineItem, :count).by(1)
      LineItem.last.tap do |line_item|
        expect(line_item.source_id).to eq(subject.organization.id)
        expect(line_item.source_type).to eq('Order')
        expect(line_item.amount).to eq(subject.total)
        expect(line_item.charge_type).to eq('credit')
      end
    end

    it 'deducts credits from the organization' do
      expect { subject.deduct_credits(subject.total.to_i) }.to change(Credit, :count).by(1)
      Credit.last.tap do |credit|
        expect(credit.source_id).to eq(subject.organization.id)
        expect(credit.source_type).to eq('Order')
        expect(credit.amount).to eq(-subject.total.to_money)
      end
    end

    context 'applying more credits than what is available' do
      before { subject.organization.credits.first.update(amount: 100) }

      it 'does not deduct credits' do
        expect { subject.deduct_credits(subject.total.to_i) }.not_to change(Credit, :count)
      end
    end
    context 'double applying credits' do
      before { subject.organization.credits.first.update(amount: subject.total.to_i - 1) }
      it 'does not deduct credits twice' do
        subject.deduct_credits(subject.total.to_i - 1)
        expect(subject.deduct_credits(1)).to be false
      end
    end
  end

  describe '#create_line_items' do
    it 'creates line items for the charges and fees on an order' do
      expect { subject.create_line_items }.to change(LineItem, :count).by((subject.fees + subject.charges).count)
    end
  end

  it '#primary_user' do
    expect(subject.primary_user).to eq subject.organization.primary_user
  end

  it '#email' do
    expect(subject.email).to eq subject.primary_user.email
  end

  describe '#future?' do
    it 'false if yesterday' do
      subject.starts_on = 1.day.ago
      expect(subject.future?).to be_falsy
    end

    it 'false if today' do
      subject.starts_on = Time.now
      expect(subject.future?).to be_falsy
    end

    it 'true if tomorrow' do
      subject.starts_on = 1.day.from_now
      expect(subject.future?).to be_truthy
    end
  end

  describe '#starts_on=' do
    context 'valid string assignments' do
      it 'is a stringized date' do
        subject.starts_on = date_string
        expect(subject.starts_on).to eq date_real
      end

      it 'is "tomorrow"' do
        # this test will fail if you are in UTC
        subject.starts_on = 'tomorrow'
        expect(subject.starts_on).to eq Date.current + 1.day
      end
    end

    it 'is a Date assignment' do
      subject.starts_on = date_real
      expect(subject.starts_on).to eq date_real
    end

    it 'is a nil assignment' do
      subject.starts_on = nil
      expect(subject.starts_on).to be_nil
    end

    it 'is a malformed date assignment' do
      subject.starts_on = 'foobar'
      expect(subject.starts_on).to be_nil
    end
  end

  describe '#status' do
    it 'is unpaid' do
      subject.paid_at = nil
      expect(subject.status).to eq :pending
    end

    it 'is cancelled' do
      subject.paid_at = nil
      subject.is_cancelled = true
      expect(subject.status).to eq :cancelled
    end

    it 'is invalid' do
      unpaid_order.ends_on = nil
      expect(unpaid_order.status).to eq :invalid
    end

    it "should cancel the order" do
      unpaid_order.cancel
      expect(unpaid_order.cancelled?).to eq true
    end

    it 'is failed' do
      subject.paid_at = nil
      subject.error_message = 'Failed'
      expect(subject.status).to eq :failed
    end

    it 'is paid' do
      expect(subject.status).to eq :paid
    end
  end

  describe '#ends_on=' do
    it 'string assignment' do
      subject.ends_on = date_string
      expect(subject.ends_on).to eq date_real
    end

    it 'date assignment' do
      subject.ends_on = date_real
      expect(subject.ends_on).to eq date_real
    end

    it 'nil assignment' do
      subject.ends_on = nil
      expect(subject.ends_on).to be_nil
    end

    it 'malformed date assignment' do
      subject.ends_on = 'foobar'
      expect(subject.ends_on).to be_nil
    end
  end

  describe '#formatted_total' do
    let(:order) { orders(:metova) }

    it 'returns the formatted total' do
      expect(order.formatted_total).to eq '$975.00'
    end
  end

  describe '#to_csv' do
    it 'returns a csv for a collection of orders' do
      csv = described_class.all.to_csv

      described_class.all.each do |order|
        record = [
          order.plan_id,
          order.paid_at,
          order.created_at,
          order.updated_at,
          order.starts_on,
          order.ends_on,
          order.po_number,
          order.payment_method_id,
          order.error_message,
          order.started_at,
          order.amount,
          order.paid,
          order.legacy_identifier
        ].join(',')

        expect(csv).to include record
        expect(csv).not_to match /translation missing/
      end
    end
  end

  describe '#adjusted_amount' do
    context 'when the amount requested is less than the total_with_credits' do
      it 'returns the amount requested' do
        amount = subject.total.to_i - 1
        expect(subject.send(:adjusted_amount, amount)).to eq(amount)
      end
    end

    context 'when the amount requested is equal to the subject.total_with_credits' do
      it 'returns the amount requested' do
        amount = subject.total.to_i
        expect(subject.send(:adjusted_amount, amount)).to eq(amount)
      end
    end

    context 'when the amount requested is greater than the total_with_credits' do
      it 'returns the order total with credits as the amount' do
        amount = subject.total.to_i + 1
        expect(subject.send(:adjusted_amount, amount)).to eq(subject.total_with_credits)
      end
    end
  end

  context 'active scope' do
    let(:count) { Order.count }

    # seriously, fix this
    it 'returns the correct number of active orders' do
      expect(Order.active.count).to eq count

      Order.second.update ends_on: Order.second.starts_on + 1.year
      expect(Order.active.count).to eq count
    end
  end

  context "ransacker filter" do
    let(:order) { orders(:metova) }
    let(:other_order) { orders(:bridge) }
    let(:product_category) { product_categories(:fashion) }
    let(:unused) { product_categories(:unused) }

    it 'should return matching order' do
      order
      order_result = Order.ransack(members_in: order.id).result
      expect(order_result.first).to eq order
    end

    it 'should not return other order' do
      order
      other_order
      order_result = Order.ransack(members_in: order.id).result
      expect(order_result.first).to_not eq other_order
    end

    it 'should return product category orders' do
      product_category
      order_result = Order.ransack(plan_product_categories_in: product_category.id).result
      expect(order_result.first).to_not be_nil
    end

    it 'when order is not available, should not return any order related to product category' do
      unused
      order_result = Order.ransack(plan_product_categories_in: unused.id).result
      expect(order_result.first).to be_nil
    end
  end
end
