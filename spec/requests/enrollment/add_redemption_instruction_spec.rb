describe 'Add redemption instruction during enrollment', type: :request do
  let(:primary_user) { users(:joseph) }
  let(:admin_user) { users(:admin) }
  let(:broker_user) { users(:broker) }
  let(:order) { orders(:metova) }
  let(:organization) { organizations(:metova) }

  before { attach_images_to_product_categories }

  context 'on success', js: true do
    it 'creates new redemption instruction' do
      [primary_user, admin_user, broker_user].each do |user|
        set_up_user(user)

        expect(page).to have_no_selector('.modal-content')
        expect(page).to have_css('.redemption-instruction', count: 3)
        expect(page).to have_css('.order_plan_product_categories_redemption_instruction_instruction', count: 3)
        instructions =  ProductCategory.find_by(redemption_instructions_editable: true).redemption_instructions.map(&:title) + ['', t('helpers.new_redemption_instruction')]
        expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', options: instructions)

        select t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
        expect(page).to have_selector('.modal-content')
        expect(page).to have_css('#new-redemption-instruction-modal.modal.fade.show')
        expect do
          within '#new-redemption-instruction-form' do
            fill_in 'redemption_instruction[title]', with: 'Cool title'
            fill_in 'redemption_instruction[description]', with: 'Cool description'
            expect(page).to have_button t('enrollment.redemption_instructions.form.create')
            find('input[name="commit"]').trigger('click')
            expect(page).to have_no_selector('.has-error')
            expect(page).to have_no_selector('.invalid-input-error')
            expect(page).to have_no_button t('enrollment.redemption_instructions.form.create')
          end
          expect(page).to have_no_selector('.modal-content')
        end.to change(RedemptionInstruction, :count).by(1)

        expect(page).to have_no_selector('#new-redemption-instruction-modal.modal.fade.show')
        expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: 'Cool title')
        expect(page).to have_content('Cool description')

        within '.enrollment-footer-actions' do
          find('input[name="commit"]').trigger 'click'
          expect(page.current_path).to eq(new_enrollment_order_member_path(order))
        end

        RedemptionInstruction.last.reload.tap do |redemption_instruction|
          expect(redemption_instruction.title).to eq 'Cool title'
          expect(redemption_instruction.description).to eq 'Cool description'
          expect(redemption_instruction.organization).to eq organization
          expect(redemption_instruction.active).to be true
        end
      end
    end
  end

  context 'on error', js: true do
    it 'does not create new redemption instruction' do
      [primary_user, admin_user, broker_user].each do |user|
        set_up_user(user)
        expect(page).to have_no_selector('.modal-content')
        select I18n.t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
        expect(page).to have_selector('.modal-content')
        expect(page).to have_css('#new-redemption-instruction-modal.modal.fade.show')
        within '#new-redemption-instruction-modal' do
          fill_in 'redemption_instruction[title]', with: ''
          fill_in 'redemption_instruction[description]', with: ''

          expect do
            click_on I18n.t('enrollment.redemption_instructions.form.create')
            expect(page).to have_selector('.has-error', count: 2)
            expect(page).to have_selector('.invalid-input-error', count: 2)
            wait_for_ajax
          end.to_not change(RedemptionInstruction, :count)
          click_on '×'
        end

        expect(page).to have_no_selector('.modal-content')
        expect(page).to have_no_selector('#new-redemption-instruction-modal.modal.fade.show')
        expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: '')
      end
    end
  end

  context 'when resubmitting with corrected information', js: true do
    it 'creates a new redemption instruction' do
      [primary_user, admin_user, broker_user].each do |user|
        set_up_user(user)
        expect(page).to have_no_selector('.modal-content')

        select t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
        expect(page).to have_selector('.modal-content')
        expect(page).to have_css('#new-redemption-instruction-modal.modal.fade.show')
        within '#new-redemption-instruction-form' do
          fill_in 'redemption_instruction[title]', with: ''
          fill_in 'redemption_instruction[description]', with: ''

          expect do
            find('input[name="commit"]').trigger('click')
            expect(page).to have_selector('.has-error', count: 2)
            expect(page).to have_selector('.invalid-input-error', count: 2)
            wait_for_ajax
          end.to_not change(RedemptionInstruction, :count)

          fill_in 'redemption_instruction[title]', with: 'Cool title'
          fill_in 'redemption_instruction[description]', with: 'Cool description'

          expect do
            find('input[name="commit"]').trigger 'click'
            expect(page).to have_no_selector('.has-error')
            expect(page).to have_no_selector('.invalid-input-error')
          end.to change(RedemptionInstruction, :count).by(1)
        end

        expect(page).to have_no_selector('#new-redemption-instruction-modal.modal.fade.show')
        expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: 'Cool title')
        expect(page).to have_content('Cool description')

        within '.enrollment-footer-actions' do
          find('input[name="commit"]').trigger 'click'
          expect(page.current_path).to eq(new_enrollment_order_member_path(order))
        end

        RedemptionInstruction.last.reload.tap do |redemption_instruction|
          expect(redemption_instruction.title).to eq 'Cool title'
          expect(redemption_instruction.description).to eq 'Cool description'
          expect(redemption_instruction.organization).to eq organization
          expect(redemption_instruction.active).to be true
        end
      end
    end
  end

  context 'with random user' do
    let(:unrelated_user) { users(:test_two) }
    before do
      sign_in unrelated_user
      visit edit_enrollment_order_path(order)
    end

    it 'redirects to home page' do
      expect(page.current_path).to eq('/')
    end
  end

  def set_up_user(user)
    sign_in user
    user.organizations << organization unless user.admin?
    visit edit_enrollment_order_path(order)
  end
end
