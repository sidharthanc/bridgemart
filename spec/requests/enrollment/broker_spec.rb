describe 'New Broker', type: :request do
  let(:user) { users(:test) }

  before do
    attach_images_to_product_categories
  end

  context 'when creating a broker' do
    before do
      visit new_enrollment_broker_path
    end

    it 'throws an error if the email has already been taken' do
      fill_out_form
      fill_in 'broker[email]', with: users(:broker).email
      click_button t('enrollment.create_account')
      expect(page).to have_content t('activemodel.errors.models.sign_up.attributes.email.taken'), count: 1
    end

    it 'shows the form to sign up as a broker' do
      expect(page).to have_field 'broker[first_name]'
      expect(page).to have_field 'broker[last_name]'
      expect(page).to have_field 'broker[email]'
      expect(page).to have_field 'broker[phone]'
      expect(page).to have_field 'broker[broker_organization_name]'
      expect(page).to have_button t('enrollment.create_account')
      expect(page).to have_content t('enrollment.brokers.new.employer_redirect')
      expect(page).to have_content t('enrollment.brokers.new.create_employer_account_link')
    end

    it 'a user is able to fill out the form' do
      fill_out_form
    end

    it 'a user is unable to submit the form if the required fields are not filled in' do
      click_button t('enrollment.create_account')
      expect(page).to have_content(t('errors.messages.blank'), count: 4)
    end

    context 'when a broker sign up form is submitted' do
      it 'creates a user' do
        fill_out_form
        expect do
          click_button t('enrollment.create_account')
        end.to change(User, :count).by(1)
        User.last.tap do |user|
          expect(user.email).to eq('email@example.com')
          expect(user.first_name).to eq('First')
          expect(user.last_name).to eq('Last')
          expect(user.broker_organization_name).to eq('Broker Org Name')
          expect(user.phone_number).to eq('(123) 456-7890')
        end
      end

      it 'sends a credentials email' do
        fill_out_form
        expect do
          click_button t('enrollment.create_account')
        end.to have_enqueued_job.on_queue('mailers')
      end

      it 'redirects to the new organization enrollment flow' do
        fill_out_form
        expect do
          click_button t('enrollment.create_account')
        end.to change(User, :count).by(1)
        expect(current_path).to eq(new_enrollment_sign_up_path)
      end

      it 'assigns the user as a broker' do
        fill_out_form
        click_button t('enrollment.create_account')
        expect(User.last.permission_groups).to match(PermissionGroup.default_for_broker)
      end
    end
  end

  def fill_out_form
    fill_in 'broker[first_name]', with: 'First'
    fill_in 'broker[last_name]', with: 'Last'
    fill_in 'broker[email]', with: 'email@example.com'
    fill_in 'broker[phone]', with: '(123) 456-7890'
    fill_in 'broker[broker_organization_name]', with: 'Broker Org Name'
  end
end
