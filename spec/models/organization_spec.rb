RSpec.describe Organization, type: :model do
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:organization_users) }
  it { is_expected.to have_many(:plans) }
  it { is_expected.to have_many(:credits) }
  it { is_expected.to have_many(:redemption_instructions) }
  it { is_expected.to have_db_column(:uuid) }

  let(:organization) { organizations(:metova) }
  let(:walmart) { organizations(:walmart) }
  let(:member) { members(:logan) }
  let(:order) { organization.members.last.order }

  describe 'cached counters' do
    before do
      Member.counter_culture_fix_counts # required due to fixtures vs factories skips hooks
    end

    it 'member count' do
      expect(organization.members_count).to eq 3 # magic factory
      organization.members.last.destroy
      organization.reload
      expect(organization.members_count).to eq 2
    end
  end

  describe 'legacy_identifier' do
    it 'restrict unique legacy_identifiers values' do
      organization.update_attribute(:legacy_identifier, 12_345)
      expect { walmart.update_attribute(:legacy_identifier, 12_345) }.to raise_error ActiveRecord::RecordNotUnique
    end

    it 'allow multiple nil legacy_identifier values' do
      organization.update_attribute(:legacy_identifier, nil)
      expect { walmart.update_attribute(:legacy_identifier, nil) }.not_to raise_error
    end
  end

  describe "#remaining_balance_at" do
    let(:credit_1) { organization.credits.create(source: organization, amount_cents: 100, created_at: Date.current - 2.days) }
    let(:credit_2) { organization.credits.create(source: organization, amount_cents: -50, created_at: Date.current - 1.day) }
    let(:credit_3) { organization.credits.create(source: organization, amount_cents: 200, created_at: Date.current) }

    it 'calculates the credit value at certain points in history' do
      expect(organization.remaining_balance_at(credit_1)).to eq 1.00.to_money
      expect(organization.remaining_balance_at(credit_2)).to eq 0.50.to_money
      expect(organization.remaining_balance_at(credit_3)).to eq 2.50.to_money
    end
  end

  describe "#active_agreement" do
    it "shows the organization associated record" do
      commercial_agreement = CommercialAgreement.new
      commercial_agreement.pdf.attach to_file('test.pdf')
      commercial_agreement.organization = organization

      expect(commercial_agreement.save).to be true
      expect(organization.active_agreement.organization_id).to eq organization.id
    end

    it "shows does not show the organization associated record" do
      commercial_agreement = CommercialAgreement.new
      commercial_agreement.pdf.attach to_file('test.pdf')

      expect(commercial_agreement.save).to be true
      expect(organization.active_agreement.organization_id).to eq nil
    end

  end

  describe '#has_signed' do
    let!(:subject) { organizations(:metova) }
    let!(:signed_agreement) { commercial_agreements(:signed_agreement) }
    let!(:unsigned_agreement) { commercial_agreements(:new_unsigned_agreement) }

    it 'returns true when the agreement has been signed' do
      expect(subject.has_signed(signed_agreement)).to eq true
    end

    it 'returns false when the agreement has not been signed' do
      expect(subject.has_signed(unsigned_agreement)).to eq false
    end
  end

  describe '#status' do
    it 'returns red if there are no orders' do
      organization = Organization.create! name: 'No Plan', industry: 'Charity', primary_user: users(:joseph)
      expect(organization.status).to eq 'red'
    end

    it 'returns green if there is an order' do
      expect(organization.status).to eq 'green'
    end
  end

  describe 'ytd_load' do
    it 'should return the total limit on codes within the year' do
      # organization.members.last.order.update starts_on: 2.years.ago
      order.starts_on = 2.years.ago
      order.save(validate: false)
      expect(organization.ytd_load).to eq 0.to_money
    end
  end

  describe "when credit_total_cached_cents column added" do
    it 'should have the column in organization' do
      expect(organization.respond_to?(:credit_total_cached_cents)).to eq true
    end
  end

  describe 'lifetime_load' do
    it 'should return the total limit on all codes' do
      sum_of_codes = Code.all.map(&:limit).sum
      expect(organization.lifetime_load).to eq sum_of_codes.to_money
    end
  end

  describe '#account_status' do
    context 'for an organization without any orders' do
      let(:organization_without_orders) { organizations(:walmart) }

      # Functionality Invalid
      xit 'returns a no_order status' do
        expect(organization_without_orders.account_status).to eq("no_order")
      end
    end

    context 'when an organization has an unpaid order that has been processed (attempted)' do
      before do
        organization.orders.sample.update(paid_at: nil, processed_at: Time.zone.now)
      end

      it 'returns a billing_issue status' do
        expect(organization.account_status.to_s).to eq("billing_issue")
      end
    end

    context 'when an organization has orders that have all been paid for' do
      before { organization.orders.pending.each { |o| o.update(paid_at: 1.day.ago) } }

      it 'returns a good status' do
        expect(organization.account_status.to_s).to eq("good")
      end
    end
  end

  describe 'authentication_token' do
    let(:organization) { build(:organization) }

    it 'automatically populates on save if empty' do
      expect(Devise).to receive(:friendly_token).and_return('my-fancy-token')
      expect { organization.save }.to change(organization, :authentication_token).from(nil).to('my-fancy-token')
    end
  end

  def to_file(name)
    { io: File.open(Rails.root.join('spec/fixtures/files/', name)), filename: name }
  end
end
