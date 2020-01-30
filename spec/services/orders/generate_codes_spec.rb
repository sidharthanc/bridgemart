describe Orders::GenerateCodes do
  include ActiveJob::TestHelper

  subject { described_class }

  let(:organization) { create(:organization) }
  let(:members) { create_list(:member, 3) }
  let(:plan) { create(:plan, organization: organization) }
  let(:order) { create(:order, :paid, members: members, plan: plan) }

  it 'touches generated_at' do
    expect { subject.execute(order) }.to change(order, :generated_at).from(nil)
  end

  it 'creates a code for each member' do
    expect { subject.execute(order) }.to change(order.codes, :count).from(0).to(3)
  end

  it 'marks order as started' do
    expect { subject.execute(order) }.to change(order, :started_at).from(nil)
  end

  it 'delivers an email for each code generated' do
    expect(CodeMailer).to receive(:registered_email).and_call_original.exactly(order.members.size).times
    subject.execute(order)
  end

  context 'codes already exist' do
    before do
      ppc = order.plan_product_categories.first
      members.first.codes.create! limit: ppc.budget, plan_product_category: ppc, virtual_card_provider: ppc.product_category.card_type.to_sym, starts_on: order.starts_on, expires_on: order.ends_on
    end

    it 'does not duplicate them' do
      expect { subject.execute(order) }.to change(order.codes, :count).from(1).to(3)
    end
  end

  context 'already generated' do
    let(:generated_order) { create(:order, generated_at: 1.day.ago) }
    it 'returns false' do
      expect(subject.execute(generated_order)).to be false
    end
  end
  context 'unpaid' do
    let(:unpaid_order) { create(:order) }
    it 'returns false' do
      expect(subject.execute(unpaid_order)).to be false
    end
  end
end
