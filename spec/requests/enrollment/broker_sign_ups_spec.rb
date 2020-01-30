describe 'Organization Enrollment as a Broker', type: :request do
  let(:broker) { users(:broker) }
  as { broker }

  before do
    attach_images_to_product_categories
  end

  context 'when enrolling an organization for the first time' do
    before do
      visit new_enrollment_sign_up_path(skip_current_organization: true)
    end

    it 'shows the new page for enrolling an organization' do
      expect(page).to have_field 'sign_up[first_name]'
      expect(page).to have_field 'sign_up[last_name]'
      expect(page).to have_field 'sign_up[email]'
      expect(page).to have_field 'sign_up[phone]'
      expect(page).to have_field 'sign_up[organization_name]'
      expect(page).to have_field 'sign_up[industry]'
      expect(page).to have_field 'sign_up[approx_employees_count]'
      expect(page).to have_field 'sign_up[approx_employees_with_safety_prescription_eyewear_count]'
      expect(page).to have_field 'sign_up[product_category_ids][]'
      expect(page).to have_button t('enrollment.next')
      expect(page).to have_no_content t('enrollment.sign_ups.new.broker_redirect')
      expect(page).to have_no_content t('enrollment.sign_ups.new.create_broker_account_link')
    end

    it 'shows a number of product category sections equal to the number of divisions that have product categories' do
      expect(page).to have_selector('.enrollment-section__division', count: 2)
    end

    it 'a user is unable to submit the form if the required fields are not filled in' do
      expect(page).to have_field 'sign_up[first_name]'
      click_button t('enrollment.next')
      expect(page).to have_content(t('errors.messages.blank'), count: 5)
      expect(page).to have_content('Please select at least one product', count: 1)
    end

    it 'has proper tooltip info for the product categories' do
      ProductCategory.all.each do |product_category|
        expect(page).to have_selector(".organization__product-category-option[title='#{product_category.tooltip_description}']")
      end
    end

    context 'when an organization enrollment form is submitted with a different primary contact' do
      it 'creates a user' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to change(User, :count).by(1)
        User.last.tap do |user|
          expect(user.email).to eq('email@example.com')
          expect(user.first_name).to eq('First')
          expect(user.last_name).to eq('Last')
          expect(user.phone_number).to eq('(123) 456-7890')
        end
      end

      it 'does not sign in the new user' do
        fill_out_form
        click_button t('enrollment.next')
        new_user = User.find_by(email: 'email@example.com')
        expect(new_user.last_sign_in_at?).to be(false)
      end

      it 'sends a credentials email' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to have_enqueued_job.on_queue('mailers')
      end

      it 'creates an organization' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to change(Organization, :count).by(1)
        new_user = User.find_by(email: 'email@example.com')
        Organization.last.tap do |organization|
          expect(organization.users).to include(broker, new_user)
          expect(organization.name).to eq('Org Name')
          expect(organization.industry).to eq('Auto')
          expect(organization.number_of_employees).to eq('100-500')
          expect(organization.number_of_employees_with_safety_rx_eyewear).to eq('Less than 100')
          expect(organization.primary_user).to eq new_user
        end
      end

      it 'assigns the new org to the primary contact' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to change(OrganizationUser, :count).by(2)
        user = User.find_by(email: 'email@example.com')
        organization = Organization.find_by(name: 'Org Name')
        expect(organization.users).to include user, broker
        expect(User.with_default_permission_for_organization).to_not include broker
        expect(organization.primary_user).to eq(user)
        expect(user.permission_groups).to include(PermissionGroup.default_for_organization.take)
      end

      it 'assigns the new org to the broker' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to change(OrganizationUser, :count).by(2)
        expect(broker.reload.organizations).to include(Organization.last)
        expect(Organization.last.users).to include broker
      end
    end

    context 'when an organization enrollment form is submitted with the broker as primary contact' do
      it 'does not create a new user' do
        fill_out_form(broker)
        expect do
          click_button t('enrollment.next')
        end.to_not change(User, :count)
      end

      it 'does not send a credentials email' do
        fill_out_form(broker)
        expect do
          click_button t('enrollment.next')
        end.to_not have_enqueued_job.on_queue('mailers')
      end

      it 'creates an organization' do
        fill_out_form(broker)
        expect do
          click_button t('enrollment.next')
        end.to change(Organization, :count).by(1)
        Organization.last.tap do |organization|
          expect(organization.users).to eq([broker])
          expect(organization.name).to eq('Org Name')
          expect(organization.industry).to eq('Auto')
          expect(organization.number_of_employees).to eq('100-500')
          expect(organization.number_of_employees_with_safety_rx_eyewear).to eq('Less than 100')
          expect(organization.primary_user).to eq(broker)
        end
      end

      it 'the new organization belongs to the broker' do
        fill_out_form(broker)
        expect do
          click_button t('enrollment.next')
        end.to change(broker.organizations, :count).by(1)
      end
    end

    context 're-visiting enrollment of an organization page after completing step' do
      let(:plan) { plans(:metova) }
      let(:organization) { plan.organization }
      before { broker.organizations << organization }

      as { broker }

      before do
        visit new_enrollment_sign_up_path(organization_id: organization)
      end

      it 'does not have organization fields' do
        expect(page).to have_no_field 'sign_up[first_name]'
        expect(page).to have_no_field 'sign_up[last_name]'
        expect(page).to have_no_field 'sign_up[email]'
        expect(page).to have_no_field 'sign_up[phone]'
        expect(page).to have_no_field 'sign_up[organization_name]'
        expect(page).to have_no_field 'sign_up[industry]'
        expect(page).to have_no_field 'sign_up[approx_employees_count]'
        expect(page).to have_no_field 'sign_up[approx_employees_with_safety_prescription_eyewear_count]'
      end

      it 'allows the broker to select product categories for a new enrollment' do
        find("#sign_up_product_category_ids_#{product_categories(:exam).id}").click
        expect do
          click_button t('enrollment.next')
        end.to change(Plan, :count).by(1)
        Plan.last.tap do |plan|
          expect(plan.organization).to eq(Organization.last)
          expect(plan.product_categories).to eq [product_categories(:exam)]
        end
      end

      it 'does not update original primary contact' do
        find("#sign_up_product_category_ids_#{product_categories(:exam).id}").click
        expect do
          click_button t('enrollment.next')
        end.to_not change(organization, :primary_user)
      end
    end
  end

  def fill_out_form(broker_user = nil)
    fill_in 'sign_up[first_name]', with: 'First'
    fill_in 'sign_up[last_name]', with: 'Last'
    fill_in 'sign_up[phone]', with: '(123) 456-7890'
    fill_in 'sign_up[organization_name]', with: 'Org Name'
    select 'Auto', from: 'sign_up[industry]'
    select '100-500', from: 'sign_up[approx_employees_count]'
    select 'Less than 100', from: 'sign_up[approx_employees_with_safety_prescription_eyewear_count]'
    find("#sign_up_product_category_ids_#{product_categories(:exam).id}").click
    find("#sign_up_product_category_ids_#{product_categories(:fashion).id}").click
    fill_in 'sign_up[email]', with: (broker_user ? broker.email : 'email@example.com')
  end
end
