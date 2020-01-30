describe 'Organization Enrollment', type: :request do
  let(:user) { users(:test_two) }

  before do
    attach_images_to_product_categories
  end

  context 'when enrolling an organization' do
    before do
      visit new_enrollment_sign_up_path
    end

    it 'shows the new page for enrolling an organization' do
      expect(page).to have_field 'sign_up[first_name]'
      expect(page).to have_field 'sign_up[last_name]'
      expect(page).to have_field 'sign_up[title]'
      expect(page).to have_field 'sign_up[email]'
      expect(page).to have_field 'sign_up[phone]'
      expect(page).to have_field 'sign_up[organization_name]'
      expect(page).to have_field 'sign_up[industry]'
      expect(page).to have_field 'sign_up[approx_employees_count]'
      expect(page).to have_field 'sign_up[approx_employees_with_safety_prescription_eyewear_count]'
      expect(page).to have_field 'sign_up[product_category_ids][]'
      expect(page).to have_button t('enrollment.next')
      expect(page).to have_content t('enrollment.sign_ups.new.broker_redirect')
      expect(page).to have_content t('enrollment.sign_ups.new.create_broker_account_link')
    end

    it 'a user is able to fill out the form' do
      fill_out_form
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

    it 'shows only visible product categories' do
      product_category = ProductCategory.all.sample
      product_category.hidden!
      visit new_enrollment_sign_up_path
      expect(page).to have_no_selector("#sign_up_product_category_ids_#{product_category.id}")
    end

    context 'when a organization enrollment form is submitted' do
      it 'creates a user' do
        fill_out_form
        expect do
          click_button t('enrollment.next')
        end.to change(User, :count).by(1)
        User.last.tap do |user|
          expect(user.email).to eq('email@example.com')
          expect(user.first_name).to eq('First')
          expect(user.last_name).to eq('Last')
          expect(user.title).to eq('Lead Peasant')
          expect(user.phone_number).to eq('(123) 456-7890')
        end
      end

      it 'validates phone number' do
        fill_out_form
        fill_in 'sign_up[phone]', with: 'hello'

        click_button t('enrollment.next')

        expect(page).to have_content I18n.t('activemodel.errors.models.sign_up.attributes.phone.invalid')
      end

      it 'signs in the new user' do
        fill_out_form
        click_button t('enrollment.next')
        user = User.find_by(email: 'email@example.com')
        expect(user.last_sign_in_at?).to be(true)
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
        Organization.last.tap do |organization|
          expect(organization.users).to eq([User.last])
          expect(organization.name).to eq('Org Name')
          expect(organization.industry).to eq('Auto')
          expect(organization.number_of_employees).to eq('100-500')
          expect(organization.number_of_employees_with_safety_rx_eyewear).to eq('Less than 100')
          expect(organization.primary_user).to eq User.last
        end
      end

      context 'with a previously used email' do
        it 'shows error and provides link for user to sign in' do
          fill_out_form
          fill_in 'sign_up[email]', with: users(:broker).email
          click_button t('enrollment.next')
          expect(page).to have_content t('activemodel.errors.models.sign_up.attributes.email.taken')
          expect(page).to have_link t('pages.home.sign_in'), href: new_user_session_path
        end
      end
    end

    it 'creates a plan and associates it to the organization' do
      fill_out_form
      expect do
        click_button t('enrollment.next')
      end.to change(Plan, :count).by(1)
      Plan.last.tap do |plan|
        expect(plan.organization).to eq(Organization.last)
        expect(plan.product_categories).to contain_exactly(product_categories(:exam), product_categories(:fashion))
      end
    end

    it 'creates an order and associates it to the organization' do
      fill_out_form
      expect do
        click_button t('enrollment.next')
      end.to change(Order, :count).by(1)
      Order.last.tap do |order|
        expect(order.organization).to eq(Organization.last)
        expect(order.starts_on).to eq Date.current
      end
    end

    it 'associates the user to the organization' do
      fill_out_form
      expect do
        click_button t('enrollment.next')
      end.to change(OrganizationUser, :count).by(1)
      user = User.last
      expect(Organization.last.users).to include user
    end
  end

  context 'visiting enrollment page after completing step' do
    let(:plan) { plans(:metova) }
    let(:organization) { plan.organization }
    let(:user) { organization.primary_user }
    as { user }

    before do
      visit new_enrollment_sign_up_path
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

    it 'allows the user to select product categories for a new enrollment' do
      find("#sign_up_product_category_ids_#{product_categories(:exam).id}").click
      expect do
        click_button t('enrollment.next')
      end.to change(Plan, :count).by(1)
      Plan.last.tap do |plan|
        expect(plan.organization).to eq(Organization.last)
        expect(plan.product_categories).to eq [product_categories(:exam)]
      end
    end
  end

  def fill_out_form
    fill_in 'sign_up[first_name]', with: 'First'
    fill_in 'sign_up[last_name]', with: 'Last'
    fill_in 'sign_up[title]', with: 'Lead Peasant'
    fill_in 'sign_up[email]', with: 'email@example.com'
    fill_in 'sign_up[phone]', with: '(123) 456-7890'
    fill_in 'sign_up[organization_name]', with: 'Org Name'
    select 'Auto', from: 'sign_up[industry]'
    select '100-500', from: 'sign_up[approx_employees_count]'
    select 'Less than 100', from: 'sign_up[approx_employees_with_safety_prescription_eyewear_count]'
    find("#sign_up_product_category_ids_#{product_categories(:exam).id}").click
    find("#sign_up_product_category_ids_#{product_categories(:fashion).id}").click
  end
end
