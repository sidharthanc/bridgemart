describe 'Password Reset', type: :request do
  let(:finance_user) { users(:joseph) }
  let(:non_finance_user) { users(:test_two) }
  let(:organization) { organizations(:metova) }

  context 'non-financial user' do
    as { non_finance_user }

    before do
      visit organization_payment_methods_path(organization)
    end

    describe '#index' do
      it 'lists each payment method, but has no edit buttons' do
        expect(page).not_to have_css '.payment-method__edit-button'
        expect(page).to have_css '.payment-method', count: organization.payment_methods.count
      end
    end

    describe '#edit' do
      let(:payment_method) { payment_methods(:credit) }

      it 'does not allow non-financial users access' do
        visit edit_organization_payment_method_path(organization, payment_method)

        expect(page).to have_content t 'errors.access_denied'
      end
    end
  end

  context 'financial user' do
    as { finance_user }

    before do
      visit organization_payment_methods_path(organization)
    end

    describe '#index' do
      describe 'nav header' do
        it 'has a link to the orders page' do
          expect(page).to have_link t('layouts.dashboard.nav.billing'), href: organization_orders_path(organization)
        end

        it 'has a link to the payment methods page' do
          expect(page).to have_link t('layouts.dashboard.nav.payment_methods'), href: organization_payment_methods_path(organization)
        end
      end

      it 'has a link to edit each payment method' do
        expect(page).to have_css '.payment-method', count: organization.payment_methods.count
        expect(page).to have_css '.payment-method__edit-button', count: organization.payment_methods.count
      end

      context 'credit' do
        it 'lists all the payment methods an order has used' do
          organization.payment_methods.each do |payment_method|
            if payment_method.payment_type == :credit
              expect(page).to have_content payment_method.credit_card_number
              expect(page).to have_content payment_method.credit_card_expiration_date
            end
          end
        end
      end

      context 'ach' do
        it 'lists all the payment methods an order has used' do
          organization.payment_methods.each do |payment_method|
            next unless payment_method.payment_type == :ach

            expect(page).to have_content payment_method.ach_account_name
            expect(page).to have_content payment_method.ach_account_number
            expect(page).to have_content payment_method.ach_account_type
          end
        end
      end
    end

    describe '#edit' do
      context 'credit' do
        let(:payment_method) { payment_methods(:credit) }

        before do
          visit edit_organization_payment_method_path(organization, payment_method)
        end

        it 'shows a form, with masked payment details in a side panel' do
          within(:css, '.payment-details') do
            expect(page).to have_content payment_method.credit_card_number
            expect(page).to have_content payment_method.credit_card_expiration_date
          end
        end

        it 'contains all the fields needed to track billing information' do
          fill_out_form(payment_method: payment_method.payment_type)
        end
      end

      context 'ach' do
        let(:payment_method) { payment_methods(:ach) }

        before do
          visit edit_organization_payment_method_path(organization, payment_method)
        end

        it 'shows a form, with masked payment details in a side panel' do
          within(:css, '.payment-details') do
            expect(page).to have_content payment_method.ach_account_name
            expect(page).to have_content payment_method.ach_account_number
            expect(page).to have_content payment_method.ach_account_type
          end
        end

        it 'contains all the fields needed to track billing information' do
          fill_out_form(payment_method: payment_method.payment_type)
        end
      end
    end
  end

  private
    def fill_out_form(payment_method = :credit)
      if payment_method == :credit
        fill_in 'cc_number', with: 4_111_111_111_111_111
        fill_in 'cc_exp', with: '10/25'
        fill_in 'cvv', with: '708'
      elsif payment_method == :ach
        fill_in 'account_name', with: 'My Business Account'
        choose 'account_type', option: 'checking'
        fill_in 'account_number', with: '123123123'
        fill_in 'routing_number', with: '123123123'
      end

      fill_in 'billing_contact[first_name]', with: 'First'
      fill_in 'billing_contact[last_name]', with: 'Last'
      fill_in 'billing_contact[email]', with: 'email@example.com'

      fill_in 'address[street1]', with: 'Billing address 1'
      fill_in 'address[street2]', with: 'Billing address 2'
      fill_in 'address[city]', with: 'Billing City'
      fill_in 'address[zip]', with: '12345'
      select 'AL', from: 'address[state]'
    end
end
