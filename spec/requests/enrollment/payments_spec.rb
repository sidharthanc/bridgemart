describe 'Billing page', type: :request, js: true do
  include ActiveJob::TestHelper
  let(:user) { users(:joseph) }
  let(:order) { orders(:metova) }
  let(:invalid_order) { orders(:bridge) }

  before do
    order.update(paid_at: nil)
    order.organization.update primary_user: user
    sign_in user
    visit new_enrollment_order_payment_path order
  end

  around(:each) do |example|
    perform_enqueued_jobs(only: PaymentJob) do
      example.run
    end
  end

  context 'pre-plan charges' do
    it 'shows pre-plan charges line items' do
      order.plan_product_categories.find_each do |plan_product_category|
        within '.pre-plan-charges-table' do
          product_fee = plan_product_category.product_fee
          bridge_fee = plan_product_category.bridge_fee

          expect(page).to have_content product_fee.description
          expect(page).to have_content humanized_money_with_symbol(product_fee.rate)
          expect(page).to have_content humanized_money_with_symbol(product_fee.rate * order.members.count)
        end
      end

      expect(page).to have_content t('enrollment.payments.form.fees').upcase
      expect(page).to have_content humanized_money_with_symbol(order.total_fees)
    end

    it 'shows the total for the pre plan charges' do
      within '#order-total' do
        expect(page).to have_content '$975.00'
      end
    end
  end

  context 'when filling out billing information' do
    before do
      visit new_enrollment_order_payment_path order
    end

    it 'shows the new page for adding billing information' do
      expect(page).to have_field 'payment[first_name]'
      expect(page).to have_field 'payment[last_name]'
      expect(page).to have_field 'payment[email]'
      expect(page).to have_field 'payment[street1]'
      expect(page).to have_field 'payment[street2]'
      expect(page).to have_field 'payment[city]'
      expect(page).to have_field 'payment[state]'
      expect(page).to have_field 'payment[zip]'
      expect(page).to have_field 'payment[po_number]'

      click_on 'Credit Card'
      expect(page).to have_field 'payment[credit_card_expiration_date]'
      expect(page).to have_field 'payment[credit_card_cvv]'

      # click_on 'ACH Bank Draft'
      # expect(page).to have_field 'payment[ach_account_name]'
      # expect(page).to have_field 'payment[ach_account_type]'

      click_on t('enrollment.payments.form.billing_methods.buttons.credits')
      expect(page).to have_button t('enrollment.payments.form.apply_credit'), disabled: true
      expect(page).to have_field 'credit-amount'

      expect(page).not_to have_button I18n.t('helpers.submit.payment.create')
    end

    it 'allows a user to fill out the form, and submit once they have agreed to the terms' do
      fill_out_form
      expect(page).to have_button I18n.t('helpers.submit.payment.create')

      fill_out_form :ach
      expect(page).to have_button I18n.t('helpers.submit.payment.create')
    end

    context 'with enough accrued credits to cover the entire cost of the order' do
      before { order.organization.credits.create!(source: order.organization, amount: order.total.dollars) }

      it 'allows a user to fill out the billing form, and submit once they have applied credits' do
        visit new_enrollment_order_payment_path order.reload
        apply_credits_to_order(order)

        expect(page).to have_button I18n.t('helpers.submit.payment.create'), disabled: false
      end
    end

    context "validates the amount of applied credit" do
      before do
        order.organization.credits.create!(source: order.organization, amount: order.total.dollars * 2)
        visit new_enrollment_order_payment_path order.reload
        click_on I18n.t('enrollment.payments.form.billing_methods.buttons.credits')
      end

      it "doesn't allow to use more credits than the order total amount" do
        fill_in 'credit-amount', with: order.total.to_i + 1
        expect(page).to have_button I18n.t('enrollment.payments.form.apply_credit'), disabled: true
      end

      it "the sum of the credits is not greater than the order total amount" do
        fill_in 'credit-amount', with: order.total.to_i - 10
        click_button t('enrollment.payments.form.apply_credit')
        expect(page).to have_selector('.close', visible: false)

        fill_in 'credit-amount', with: 11
        expect(page).to have_button I18n.t('enrollment.payments.form.apply_credit'), disabled: true
      end
    end

    context 'with partial accrued credits to contribute to the cost of the order' do
      before { order.organization.credits.create!(source: order.organization, amount: order.total.dollars - 10) }

      it 'allows a user to fill out the form, but not submit' do
        visit new_enrollment_order_payment_path order.reload
        apply_credits_to_order(order)

        expect(page).to have_button I18n.t('helpers.submit.payment.create'), disabled: true
      end
    end

    it 'prefills the billing contact information from the user' do
      expect(find('input#payment_first_name').value).to eq user.first_name
      expect(find('input#payment_last_name').value).to eq user.last_name
      expect(find('input#payment_email').value).to eq user.email
    end

    context 'filling out payment options' do
      it "disables credit card fields when we're paying with ach" do
        fill_out_form :credit
        # expect(page).to have_cc_field
        expect(page).to have_field 'payment[credit_card_expiration_date]'
        expect(page).to have_field 'payment[credit_card_cvv]'

        fill_out_form :ach
        # expect(page).not_to have_ach_field
        expect(page).not_to have_field 'payment[credit_card_expiration_date]'
        expect(page).not_to have_field 'payment[credit_card_cvv]'
      end

      it "disables ach fields when we're paying with credit card" do
        fill_out_form :ach
        expect(page).to have_field 'payment[ach_account_name]'
        expect(page).to have_field 'payment[ach_account_type]'

        fill_out_form :credit
        expect(page).not_to have_field 'payment[ach_account_name]'
        expect(page).not_to have_field 'payment[ach_account_type]'
      end

      context 'when applying credits' do
        context 'where partial cost is covered by credits' do
          before do
            order.organization.credits.create!(source: order.organization, amount: order.total.dollars - 1)
            visit new_enrollment_order_payment_path order.reload
            apply_credits_to_order(order)
          end

          it "disables credit card fields when we're paying with ach for the remainder of the order" do
            fill_out_form :credit
            # expect(page).to have_cc_field
            expect(page).to have_field 'payment[credit_card_expiration_date]'
            expect(page).to have_field 'payment[credit_card_cvv]'

            fill_out_form :ach
            # expect(page).not_to have_cc_field
            expect(page).not_to have_field 'payment[credit_card_expiration_date]'
            expect(page).not_to have_field 'payment[credit_card_cvv]'
          end

          it "disables ach fields when we're paying with credit card for the remainder of the order" do
            fill_out_form :ach
            expect(page).to have_field 'payment[ach_account_name]'
            expect(page).to have_field 'payment[ach_account_type]'
            # expect(page).to have_field 'payment[ach_account_number]'
            # expect(page).to have_field 'payment[ach_routing_number]'

            fill_out_form :credit
            expect(page).not_to have_field 'payment[ach_account_name]'
            expect(page).not_to have_field 'payment[ach_account_type]'
            # expect(page).not_to have_field 'payment[ach_account_number]'
            # expect(page).not_to have_field 'payment[ach_routing_number]'
          end
        end
      end
    end

    context 'bridge terms and agreement', js: true do
      it 'are available via a modal' do
        expect(page).to have_css('.click-text', count: 1)
        all('.click-text').last.click
        expect(page).to have_content(I18n.t('.enrollment.payments.form.terms_and_conditions.title_html'))
        expect(page).to have_content(I18n.t('.enrollment.payments.form.terms_and_conditions.button_text'))
        expect(page).to have_css("input#payment_terms_and_conditions[disabled]")
      end

      it 'must be agreed upon before a user can click the checkbox' do
        expect(page.find("input#payment_terms_and_conditions")).to_not be_checked
        expect(page).to have_css("input#payment_terms_and_conditions[disabled]")
        fill_out_form
        expect(page.find("input#payment_terms_and_conditions")).not_to be_disabled
        expect(page.find("input#payment_terms_and_conditions")).to be_checked
      end

      it 'prevents users from checking box unless they agree' do
        all('.click-text').last.click
        first('.close').click
        expect(page).to have_css("input#payment_terms_and_conditions[disabled]")
      end

      it 'checks the checkbox when a user agrees to the terms and conditions' do
        expect(page.find("input#payment_terms_and_conditions")).to_not be_checked
        expect(page).to have_css("input#payment_terms_and_conditions[disabled]")

        all('.click-text').last.click
        click_button(I18n.t('.enrollment.payments.form.terms_and_conditions.button_text'))

        expect(page.find("input#payment_terms_and_conditions")).not_to be_disabled
        expect(page.find("input#payment_terms_and_conditions")).to be_checked
      end
    end

    context 'when billing information is submitted' do
      context 'failing validations' do
        it 'does not submit without accepting the terms and conditions' do
          fill_out_form
          uncheck 'payment[terms_and_conditions]'
          expect(page).not_to have_button I18n.t('helpers.submit.payment.create')
        end
      end

      context 'passing validations' do
        before do
          allow(CardConnect::Service::Authorization).to receive(:new)
            .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))
        end

        it 'submits the form passing credit card data' do
          fill_out_form
          wait_for_ajax
          click_button I18n.t('helpers.submit.payment.create')
          wait_for_ajax

          expect(page.current_path).to eq dashboard_path
        end

        it 'submits the form passing ACH Account data' do
          fill_out_form :ach
          wait_for_ajax
          click_button I18n.t('helpers.submit.payment.create')
          wait_for_ajax

          expect(page.current_path).to eq dashboard_path
        end

        context 'where total cost is covered by credits' do
          before do
            order.organization.credits.create!(source: order.organization, amount: order.total.dollars)
            visit new_enrollment_order_payment_path order.reload
          end

          it 'the order is submitted successfully without credit card or ach info' do
            apply_credits_to_order(order)
            click_button I18n.t('helpers.submit.payment.create')
            wait_for_ajax

            expect(page.current_path).to eq dashboard_path
            expect(order.total_with_credits).to eq(0.to_money)
            expect(order.payment_method).to eq(nil)
          end
        end

        context 'where partial cost is covered by credits' do
          before do
            order.organization.credits.create!(source: order.organization, amount: order.total.dollars - 1)
            visit new_enrollment_order_payment_path order.reload
          end

          it 'the order can not submitted without credit card or ach info' do
            apply_credits_to_order(order)
            wait_for_ajax
            expect(page).to have_button I18n.t('helpers.submit.payment.create'), disabled: true
          end

          it 'the order is submitted successfully with credit card information to cover the rest of the order cost' do
            apply_credits_to_order(order)
            fill_out_form
            wait_for_ajax
            click_button I18n.t('helpers.submit.payment.create')
            wait_for_ajax
            expect(page.current_path).to eq dashboard_path
            expect(order.total_with_credits).to eq(1.to_money)
          end

          it 'the order is submitted successfully with ach information to cover the rest of the order cost' do
            apply_credits_to_order(order)
            fill_out_form(:ach)
            wait_for_ajax
            click_button I18n.t('helpers.submit.payment.create')
            wait_for_ajax
            expect(page.current_path).to eq dashboard_path
            expect(order.total_with_credits).to eq(1.to_money)
          end
        end
      end
    end

    def fill_out_form(payment_method = :credit)
      all('.click-text').last.click
      click_button(I18n.t('.enrollment.payments.form.terms_and_conditions.button_text'))

      if payment_method == :credit
        click_on I18n.t('enrollment.payments.form.billing_methods.buttons.credit_card')

        src = 'window.postMessage(JSON.stringify({"ccToken":"9411111111111112","token":"9417119164771111","errorCode":"0","errorMessage":"","entry":"manual"}), "*")'
        page.execute_script(src)

        fill_in 'payment[credit_card_expiration_date]', with: '10/25'
        fill_in 'payment[credit_card_cvv]', with: '708'
      elsif payment_method == :ach
        click_on I18n.t('enrollment.payments.form.billing_methods.buttons.ach_bank_draft')
        fill_in 'payment[ach_account_name]', with: 'My Business Account'
        choose 'payment[ach_account_type]', option: 'checking'

        src = 'window.postMessage(JSON.stringify({"achToken":"9411111111111112","token":"9417119164771111","errorCode":"0","errorMessage":"","entry":"manual"}), "*")'
        page.execute_script(src)
      end

      fill_in 'payment[first_name]', with: 'First'
      fill_in 'payment[last_name]', with: 'Last'
      fill_in 'payment[email]', with: 'email@example.com'
      fill_in 'payment[po_number]', with: 'PO Number'
      fill_in 'payment[street1]', with: 'Billing address 1'
      fill_in 'payment[street2]', with: 'Billing address 2'
      fill_in 'payment[city]', with: 'Billing City'
      fill_in 'payment[zip]', with: '12345'
      select 'AL', from: 'payment[state]'
      check 'payment[terms_and_conditions]'
    end

    def apply_credits_to_order(order)
      click_on I18n.t('enrollment.payments.form.billing_methods.buttons.credits')
      fill_in 'credit-amount', with: order.organization.credit_total.amount.to_i
      click_button t('enrollment.payments.form.apply_credit')
      expect(page).to have_selector('.close', visible: false)
      all('.click-text').last.click
      click_button(I18n.t('.enrollment.payments.form.terms_and_conditions.button_text'))
      check 'payment[terms_and_conditions]'
    end

    def edit_form
      all('.click-text').last.click
      click_button(I18n.t('.enrollment.payments.form.terms_and_conditions.button_text'))

      click_on 'Credit Card'
      page.find('#credit_card_token').set '95111111111111'
      fill_in 'payment[credit_card_expiration_date]', with: '10/25'
      fill_in 'payment[credit_card_cvv]', with: '708'

      all('.click-text').first.click
      all('.modal-footer button').first.click
      check 'payment_payment_terms'

      fill_in 'payment[first_name]', with: 'First2'
      fill_in 'payment[last_name]', with: 'Last2'
      fill_in 'payment[email]', with: 'email2@example.com'
      fill_in 'payment[street1]', with: 'Billing address 12'
      fill_in 'payment[street2]', with: 'Billing address 22'
      fill_in 'payment[city]', with: 'Billing City2'
      fill_in 'payment[zip]', with: '12346'
      select 'TN', from: 'payment[state]'
      check 'payment[terms_and_conditions]'
    end
  end
end
