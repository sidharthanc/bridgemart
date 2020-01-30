describe 'Importing members manually', type: :request do
  as { users(:joseph) }

  let(:form) { Enrollment::MemberForm.new }
  let(:order) { orders(:metova) }
  let(:organization_address) { order.organization.address }
  let(:address_attributes) { %w[street1 street2 city state zip] }

  before { visit new_enrollment_order_member_path(order, mode: :manual, add_member: true) }

  context 'success' do
    it 'has the proper header' do
      expect(page).to have_content I18n.t('enrollment.members.form.legend.new_member')
    end

    it 'adds the member to the database' do
      form.fill
      form.submit
      expect(page).to have_content '1 Member Saved'

      Member.last.tap do |member|
        expect(member.first_name).to eq 'Test'
        expect(member.last_name).to eq 'Testerson'
        expect(member.email).to eq 'test@metova.com'
        expect(member.phone).to eq '(123) 456-7890'
        expect(member.address.street1).to eq '3301 Aspen Grove Dr'
        expect(member.address.city).to eq 'Franklin'
        expect(member.address.state).to eq 'TN'
        expect(member.address.zip).to eq '37067'
        expect(member.order).to eq order
      end
    end

    it "adds the member to the database without an address which will default to organization's first payment method address" do
      form.fill address: false
      form.submit
      expect(page).to have_content '1 Member Saved'

      Member.last.tap do |member|
        expect(member.first_name).to eq 'Test'
        expect(member.last_name).to eq 'Testerson'
        expect(member.email).to eq 'test@metova.com'
        expect(member.phone).to eq '(123) 456-7890'
        expect(member.address.slice(*address_attributes)).to eq organization_address.slice(*address_attributes)
        expect(member.order).to eq order
      end
    end

    it 'resets the form' do
      form.fill
      form.submit
      expect(page).to have_content '1 Member Saved'
    end

    it 'adds the member to the side nav' do
      form.fill
      form.submit
      within '#member-list' do
        expect(page).to have_content 'Testerson, Test'
      end
    end

    it 'shows the number of members that have been added' do
      form.fill && form.submit
      expect(page).to have_content '1 Member Saved'
      visit new_enrollment_order_member_path(order, mode: :manual, add_member: true)
      form.fill && form.submit
      expect(page).to have_content '2 Members Saved'
    end

    it 'shows external member id field to be filled' do
      expect(page).to have_content 'External Member Id'
      expect(page).to have_selector '#member_external_member_id'
    end
  end

  context 'error' do
    it 'shows the errors on the form' do
      form.fill
      fill_in 'member[email]', with: ''
      form.submit
      expect(page).to have_content "Email can't be blank"
    end
  end
end
