RSpec.describe Member, type: :model do
  it { is_expected.to be_auditable }
  it { is_expected.to have_db_column(:uuid) }

  context 'persisted subject' do
    subject { members(:logan) }
    it_has_behavior 'deactivatable'
  end

  describe '#valid?' do
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to allow_value('(000) 000-0000').for(:phone) }
    it { is_expected.to_not allow_value('000-000-0000').for(:phone) }

    xit 'does not allow numbers in first name' do
      subject.first_name = 'Test123'
      expect(subject).to be_invalid
      expect(subject.errors.details[:first_name]).to include hash_including(error: :invalid)
    end

    xit 'does not allow numbers in last name' do
      subject.last_name = 'Test123'
      expect(subject).to be_invalid
      expect(subject.errors.details[:last_name]).to include hash_including(error: :invalid)
    end
  end

  describe '#require_address?' do
    it 'should be false' do
      expect(subject.require_address?).to be false
    end
  end

  describe '#mark_address_for_removal' do
    before do
      subject.address = addresses(:logan)
    end

    it 'removes the address if the fields are blank' do
      subject.address.street1 = nil
      subject.address.street2 = nil
      subject.address.city = nil
      subject.address.state = nil
      subject.address.zip = nil

      subject.mark_address_for_removal

      expect(subject.address).to be_marked_for_destruction
    end

    it 'does not remove the address if the fields are not blank' do
      subject.mark_address_for_removal
      expect(subject.address).to_not be_marked_for_destruction
    end
  end

  describe '#self.usage_percentage' do
    before do
      code = Member.first.codes.create limit: 300, plan_product_category: PlanProductCategory.last
      code.usages.create amount: 200
    end

    it 'returns the percentage of users with a usage' do
      expect(Member.all.usage_percentage_as_decimal).to eq 1 / 2.to_f
    end
  end

  it 'creates an address through nested attributes' do
    member = Member.new(
      order: orders(:metova),
      first_name: 'Test',
      last_name: 'Testerson',
      email: 'test@metova.com',
      address_attributes: {
        street1: '3301 Aspen Grove Dr',
        city: 'Franklin',
        state: 'TN',
        zip: '37067'
      }
    )
    expect { member.save }.to change(Address, :count).by 1
  end

  it 'updates the address' do
    member = members(:logan)
    address = member.address

    expect do
      member.update address_attributes: { id: address.id, state: 'PA' }
    end.to change {
      address.reload.state
    }.to 'PA'
  end

  context 'member address prefill' do
    let(:payment_method_address) { addresses(:bridge) }
    let(:address_attributes) { %w[street1 street2 city state zip] }
    let(:franklin) { addresses(:franklin) }

    it "uses the organization first payment method's address if address is empty" do
      member = Member.new(
        order: orders(:bridge),
        first_name: 'Test',
        last_name: 'Testerson',
        email: 'test@metova.com'
      )

      member.save!
      expect(member.address.slice(*address_attributes)).to eq payment_method_address.slice(*address_attributes)
    end

    it 'does not overwrite an existing member address' do
      member = Member.new(
        order: orders(:bridge),
        first_name: 'Test',
        last_name: 'Testerson',
        email: 'test@metova.com',
        address_attributes: {
          street1: franklin.street1,
          city: franklin.city,
          state: franklin.state,
          zip: franklin.zip
        }
      )

      member.save!
      expect(member.address.slice(*address_attributes)).to eq franklin.slice(*address_attributes)
    end
  end
end
