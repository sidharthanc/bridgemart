describe 'Organization Portal Organization', type: :request do
  let(:plan) { plans(:metova) }
  let(:organization) { plan.organization }
  let(:user) { organization.primary_user }
  let(:non_admin_user) { users(:test_two) }
  let(:metova) { organizations(:metova) }
  let(:order) { plan.orders.last }

  context 'visiting the page as a non-admin' do
    as { non_admin_user }

    before do
      visit edit_organization_organization_path(metova)
    end

    it 'shows disabled fields instead of the usual form, and hides the update button' do
      expect(page).to have_selector('#organization_portal_organization_contact_phone:disabled')
      expect(page).to have_selector('#organization_portal_organization_organization_name:disabled')
      expect(page).to have_selector('#organization_portal_organization_organization_industry:disabled')
      expect(page).to have_selector('#organization_portal_organization_organization_number_of_employees:disabled')
      expect(page).to have_selector('#organization_portal_organization_number_of_employees_with_safety_rx_eyewear:disabled')
    end
  end

  context 'visiting organization portal edit page' do
    as { user }

    before do
      user.update phone_number: '(414) 123-4567'

      order.update starts_on: 1.day.ago

      visit edit_organization_organization_path(organization)
    end

    it 'shows the fields' do
      expect(page).to have_selector('#organization_portal_organization_contact_phone:enabled')
      expect(page).to have_selector('#organization_portal_organization_organization_name:enabled')
      expect(page).to have_selector('#organization_portal_organization_organization_industry:enabled')
      expect(page).to have_selector('#organization_portal_organization_organization_number_of_employees:enabled')
      expect(page).to have_selector('#organization_portal_organization_number_of_employees_with_safety_rx_eyewear:enabled')
      expect(page).to have_selector('#organization_portal_organization_street1:enabled')
      expect(page).to have_selector('#organization_portal_organization_city:enabled')
      expect(page).to have_selector('#organization_portal_organization_state:enabled')
      expect(page).to have_selector('#organization_portal_organization_zip:enabled')
    end

    it 'pre-fills existing organization portal data' do
      expect(page).to have_selector("input[value='#{user.phone_number}']")
      expect(page).to have_selector("input[value='#{organization.name}']")
      expect(page).to have_select('organization_portal_organization[organization_industry]', selected: organization.industry)
      expect(page).to have_select('organization_portal_organization[organization_number_of_employees]', selected: organization.number_of_employees)
      expect(page).to have_select('organization_portal_organization[number_of_employees_with_safety_rx_eyewear]', selected: organization.number_of_employees_with_safety_rx_eyewear)
      expect(page).to have_selector("input[value='#{organization.address.street1}']")
      expect(page).to have_selector("input[value='#{organization.address.city}']")
      expect(page).to have_select("organization_portal_organization[state]", selected: organization.address.state)
      expect(page).to have_selector("input[value='#{organization.address.zip}']")
    end

    context 'when editing an organization' do
      before do
        edit_form
        edit_address
        click_button I18n.t('helpers.submit.organization_portal_organization.update')
      end

      it 'updates the primary contact fields' do
        expect(user.reload.phone_number).to eq '(000) 000-0000'
      end

      it 'updates organization fields' do
        expect(organization.reload.name).to eq('Org Name 2')
        expect(organization.industry).to eq('Charity')
        expect(organization.number_of_employees).to eq('1000-5000')
        expect(organization.number_of_employees_with_safety_rx_eyewear).to eq('100-500')
      end

      it 'updates the primary address of the organization' do
        expect(organization.address.reload.street1).to eq '135 Secret Glenn Rd'
        expect(organization.address.reload.city).to eq 'Snake River Rapids'
        expect(organization.address.reload.state).to eq 'ID'
      end
    end
  end

  def edit_form
    fill_in 'organization_portal_organization[contact_phone]', with: '(000) 000-0000'
    fill_in 'organization_portal_organization[organization_name]', with: 'Org Name 2'
    select 'Charity', from: 'organization_portal_organization[organization_industry]'
    select '1000-5000', from: 'organization_portal_organization[organization_number_of_employees]'
    select '100-500', from: 'organization_portal_organization[number_of_employees_with_safety_rx_eyewear]'
  end

  def edit_address
    fill_in 'organization_portal_organization[street1]', with: '135 Secret Glenn Rd'
    fill_in 'organization_portal_organization[city]', with: 'Snake River Rapids'
    select 'ID', from: 'organization_portal_organization[state]'
  end
end
