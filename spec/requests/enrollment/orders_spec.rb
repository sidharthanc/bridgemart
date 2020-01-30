describe 'Product Detail Enrollment', type: :request do
  let(:user) { users(:test) }
  let(:order) { orders(:metova_unpaid) }
  let(:organization) { organizations(:metova) }

  before do
    attach_images_to_product_categories
    sign_in user
    user.organizations << organization
    visit edit_enrollment_order_path(order)
  end

  context 'when adding product details to a plan' do
    it 'a user is able to fill out the form and update the plan', js: true do
      fill_out_form
      expect(page).to have_field 'order[starts_on]'
      expect(page).to have_field 'order[ends_on]'
      expect(page).to have_button I18n.t('helpers.submit.order.update')

      click_button I18n.t('helpers.submit.order.update')
      expect(order.reload.starts_on).to eq(Date.current.to_date)
      # Hack to work around the leap year in 2020. Refactor when a better solution presents itself
      expect(order.reload.ends_on).to be_within(1).of(1.year.from_now.to_date)
    end

    context 'budget amounts' do
      it 'are committed when user clicks off of input', js: true do
        expect(page).to have_field 'order[plan_product_categories_attributes][0][budget]'
        fill_in('order[plan_product_categories_attributes][0][budget]', with: 123)
        first('.card-title').click
        expect(find_field('order[plan_product_categories_attributes][0][budget]').value).to eq('123')
      end

      it 'accept inputs up to .01', js: true do
        find('#order_plan_product_categories_attributes_0_budget').set("100.3455\n")
        expect(find_field('order[plan_product_categories_attributes][0][budget]').value).to eq('100.35')
      end

      it 'round inputs to nearest whole dollar', js: true do
        find('#order_plan_product_categories_attributes_0_budget').set("100.99999\n")
        expect(find_field('order[plan_product_categories_attributes][0][budget]').value).to eq('101')
      end

      it 'render single decimal inputs to the hundreths place', js: true do
        find('#order_plan_product_categories_attributes_0_budget').set("100.3\n")
        expect(find_field('order[plan_product_categories_attributes][0][budget]').value).to eq('100.30')
      end
    end

    context 'with previously start and end dates' do
      before do
        order.update(starts_on: 5.days.from_now, ends_on: (1.year + 5.days).from_now)
        visit edit_enrollment_order_path(order)
      end

      it 'the ends_on date is automatically set a year from the starts_on date', js: true do
        # Hack to work around the leap year in 2020. Refactor when a better solution presents itself
        order_ends_on = Date.strptime(find_field('order[ends_on]').value, '%m/%d/%Y')
        expect(order_ends_on).to be_within(1).of((1.year + 5.days).from_now.to_date)
      end

      it 'the starts_on date is automatically set to the current starts_on date', js: true do
        expect(find_field('order[starts_on]').value).to eq(format_date(5.days.from_now))
      end
    end

    it 'a user cannot select a start date that is before the current date' do
      fill_in 'order_starts_on', with: format_date(Date.yesterday)
    end

    context 'with a product plan category without a set budget' do
      before do
        order.plan_product_categories.each do |plan_product_category|
          plan_product_category.update_attribute(:budget, 0)
        end
        visit edit_enrollment_order_path(order)
      end

      it 'the product amounts are automatically set to the basic or regular exam price', js: true do
        order.plan_product_categories.each_with_index do |plan_product_category, index|
          basic_price_point = plan_product_category.product_category.price_boundary(limit_type: :basic)
          basic_text = basic_price_point.item_name
          expect(page).to have_content("Each member can afford a #{basic_text}.")
          expect(find_field("order[plan_product_categories_attributes][#{index}][budget]").value).to eq(basic_price_point.limit.to_s)
        end
      end

      context 'with previously set budgets', js: true do
        before do
          order.plan_product_categories.each_with_index do |ppc, index|
            ppc.update_attribute(:budget, (100 + index))
          end
          visit edit_enrollment_order_path(order)
        end

        it 'renders the budget values for editing' do
          order.plan_product_categories.each_with_index do |ppc, index|
            within "#plan-product-category-#{ppc.id}" do
              expect(find_field("order[plan_product_categories_attributes][#{index}][budget]").value).to eq(ppc.budget.to_i.to_s)
            end
          end
        end
      end
    end

    # TODO: Fix the Slider Value
    xit 'the user can set the budget amounts for the cards', js: true do
      value = 1234
      order.plan_product_categories.each_with_index do |_plan_product_category, index|
        find("#order_plan_product_categories_attributes_#{index}_budget").set("#{value}\n")
      end
      click_button I18n.t('helpers.submit.order.update')
      order.reload.plan_product_categories.each do |plan_product_category|
        expect(plan_product_category.reload.budget).to eq(value.to_money)
      end
    end

    context 'Card Usage' do
      let(:plan_product_category) { order.plan_product_categories.first }

      it 'the user sets the card usage to one-use', js: true do
        within("#plan-product-category-#{plan_product_category.id}") do
          choose t('enumerize.plan_product_category.usage_type.single_use')
        end
        click_button t('helpers.submit.order.update')
        expect(page).to have_content t('enrollment.members.new.header')
        expect(plan_product_category.reload).to be_single_use
      end

      it 'the user sets the card usage to multiple-use', js: true do
        within("#plan-product-category-#{plan_product_category.id}") do
          choose t('enumerize.plan_product_category.usage_type.multi_use')
        end
        click_button t('helpers.submit.order.update')
        expect(plan_product_category.reload).to be_multi_use
      end

      it 'only has single use options if the product category is single use only', js: true do
        ProductCategory.update_all single_use_only: true
        visit edit_enrollment_order_path(order)

        expect(page).to have_content t('enumerize.plan_product_category.usage_type.single_use')
        expect(page).to_not have_content t('enumerize.plan_product_category.usage_type.multi_use')
      end
    end

    describe 'Product Description' do
      let(:product_category) { product_categories(:fashion) }

      context 'has no product description' do
        it 'does not show the product description' do
          expect(page).to have_no_content t('enrollment.orders.form.product_description')
          expect(page).to have_no_css('.ri-tooltip', text: t('enrollment.orders.form.product_description_anchor'))
        end
      end

      context 'has product description', js: true do
        before do
          product_category.update product_description: 'The quick brown fox jumps over the lazy dog'
          visit edit_enrollment_order_path(order)
        end

        it 'shows the product description title and anchor' do
          expect(page).to have_content t('enrollment.orders.code_amount.product_description')
          expect(page).to have_css('.ri-tooltip', text: t('enrollment.orders.code_amount.product_description_anchor'))
        end

        it 'has the tooltip invisible not on hover' do
          find('.ri-tooltip', match: :first).hover
          expect(page).to have_no_content product_category.product_description
        end

        it 'has the tooltip visible on hover' do
          all('.ri-tooltip')[1].hover
          expect(page).to have_content product_category.product_description
        end
      end
    end

    context 'without price points' do
      before do
        order.product_categories.each do |ppc|
          ppc.price_points.destroy_all
        end
        visit edit_enrollment_order_path(order)
      end

      it 'shows no sliders for a plan_product_category' do
        order.product_categories.each do |ppc|
          within "#plan-product-category-#{ppc.id}" do
            expect(page).to have_no_content('.vue-component-slider')
          end
        end
      end
    end

    context 'without price points but product_category has budget', js: true do
      before do
        PricePoint.destroy_all
        visit edit_enrollment_order_path(order)
      end

      it 'shows no sliders for the plan_product_category' do
        order.plan_product_categories.each do |ppc|
          within "#plan-product-category-#{ppc.id}" do
            expect(page).to have_no_content('.vue-component-slider')
          end
        end
      end

      it 'automatically uses the budget as its input value' do
        order.plan_product_categories.each_with_index do |ppc, index|
          within "#plan-product-category-#{ppc.id}" do
            expect(find_field("order[plan_product_categories_attributes][#{index}][budget]").value).to eq(ppc.budget.to_i.to_s)
          end
        end
      end
    end

    context 'with one price point and no budget for the product_category', js: true do
      before do
        PricePoint.destroy_all
        Usage.destroy_all
        order.plan.product_categories.destroy_all
        pc = order.plan.product_categories.create(name: 'Specialty Item', division: Division.first, card_type: 'first_data') do |product_category|
          attach_test_image(product_category)
        end

        pc.price_points.create(limit: 70)
        visit edit_enrollment_order_path(order)
      end

      it 'shows no sliders for the plan_product_category' do
        order.plan_product_categories.each do |ppc|
          within "#plan-product-category-#{ppc.id}" do
            expect(page).to have_no_content('.vue-component-slider')
          end
        end
      end

      it 'automatically uses the single price point as its input value' do
        expect(find_field('order[plan_product_categories_attributes][0][budget]').value).to eq('70')
      end
    end

    context 'using the slider component', js: true do
      let!(:plan_product_category) { plan_product_categories(:fashion) }

      context 'when the input is within the slider range values' do
        let!(:input_value) { plan_product_category.product_category.price_boundary(limit_type: :mid_range).limit }
        before { find('#order_plan_product_categories_attributes_1_budget').set("#{input_value}\n") }

        it 'sets the slider to the input value' do
          within "#plan-product-category-#{plan_product_category.id}" do
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(input_value.to_s)
          end
        end

        it 'displays slider verbiage text for mid-range' do
          mid_range_price_point = plan_product_category.product_category.price_boundary(limit_type: :mid_range)
          expect(page).to have_content(mid_range_price_point.verbiage)
        end
      end

      context 'input is less than the minimum slider value' do
        let(:input_value) { plan_product_category.product_category.price_boundary(limit_type: :opening).limit }

        before do
          find("#order_plan_product_categories_attributes_1_budget").set("#{input_value}\n")
        end

        it 'sets the slider to the base limit' do
          within "#plan-product-category-#{plan_product_category.id}" do
            minimum_value = plan_product_category.product_category.price_boundary(limit_type: :basic).limit
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(input_value.to_s)
          end
        end

        it 'displays slider verbiage text for below basic and subtext to upgrade' do
          within "#plan-product-category-#{plan_product_category.id}" do
            basic_price_point = plan_product_category.product_category.price_boundary(limit_type: :basic)
            opening_price_point = plan_product_category.product_category.price_boundary(limit_type: :opening)
            difference = basic_price_point.limit - input_value
            expect(page).to have_content("Each member can afford a #{opening_price_point.item_name}.")
            expect(page).to have_content("$#{difference} more to upgrade to a #{basic_price_point.item_name}.")
          end
        end
      end

      context 'input is less than the minimum slider value and opening price' do
        let(:input_value) { plan_product_category.product_category.price_boundary(limit_type: :opening).limit - 10 }

        before do
          find("#order_plan_product_categories_attributes_1_budget").set("#{input_value}\n")
        end

        it 'sets the slider to the base limit' do
          within "#plan-product-category-#{plan_product_category.id}" do
            minimum_value = plan_product_category.product_category.price_boundary(limit_type: :basic).limit
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(input_value.to_s)
          end
        end

        it 'displays slider verbiage text for below opening and subtext to upgrade' do
          within "#plan-product-category-#{plan_product_category.id}" do
            opening_price_point = plan_product_category.product_category.price_boundary(limit_type: :opening)
            difference = opening_price_point.limit - input_value
            expect(page).to have_content("Each member will be $#{difference} short of a #{opening_price_point.item_name}.")
            expect(page).to have_content("$#{difference} more to upgrade to a #{opening_price_point.item_name}.")
          end
        end
      end

      context 'input is more than the maximum slider value' do
        let!(:maximum_value) { plan_product_category.product_category.price_boundary(limit_type: :high_end).limit }
        let!(:input_value) { maximum_value + 100 }

        before do
          find("#order_plan_product_categories_attributes_1_budget").set("#{input_value}\n")
        end

        it 'sets the slider to the maximum limit' do
          within "#plan-product-category-#{plan_product_category.id}" do
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(input_value.to_s)
          end
        end

        it 'displays slider verbiage text for high end' do
          within "#plan-product-category-#{plan_product_category.id}" do
            high_end_price_point = plan_product_category.product_category.price_boundary(limit_type: :high_end)
            expect(page).to have_content("Each member can afford a #{high_end_price_point.item_name}.")
          end
        end
      end

      context 'when hovering over the slider limits' do
        context 'for an exam card' do
          it 'shows the tooltips' do
            within "#plan-product-category-#{plan_product_categories.first.id}" do
              expect(page).to have_css("#plan-product-category-#{plan_product_categories.first.id} .vue-slider-component", visible: :all)
              expect(find("#plan-product-category-#{plan_product_categories.first.id} li #high-end div", match: :first)['data-original-title']).to eq('Members can afford a contact lens fitting')
            end
          end
        end

        context 'for a glasses and contacts card' do
          context 'basic limit' do
            it 'shows the tooltip' do
              price_point = plan_product_category.product_category.price_boundary(limit_type: :basic)
              within "#plan-product-category-#{plan_product_category.id}" do
                expect(find("#plan-product-category-#{plan_product_category.id} li #basic div", match: :first)['data-original-title']).to eq(price_point.tooltip)
              end
            end
          end

          context 'mid range limits' do
            it 'shows the tooltip' do
              price_points = plan_product_category.product_category.price_points.where(limit_type: :mid_range)
              price_points.each do |price_point|
                within "#plan-product-category-#{plan_product_category.id}" do
                  expect(find("#plan-product-category-#{plan_product_category.id} li #mid-range-#{price_point.limit} div", match: :first)['data-original-title']).to eq(price_point.tooltip)
                end
              end
            end
          end

          context 'high end limit' do
            it 'shows the tooltip' do
              price_point = plan_product_category.product_category.price_boundary(limit_type: :high_end)
              within "#plan-product-category-#{plan_product_category.id}" do
                expect(find("#plan-product-category-#{plan_product_category.id} li #high-end div", match: :first)['data-original-title']).to eq(price_point.tooltip)
              end
            end
          end
        end
      end

      context 'clicking the slider' do
        # TODO: Fix Slider Value
        xit 'sets their input', js: true do
          within "#plan-product-category-#{plan_product_category.id}" do
            mid_range_value = plan_product_category.product_category.price_points.where(limit_type: :mid_range).first.limit
            high_end_value = plan_product_category.product_category.price_boundary(limit_type: :high_end).limit
            find(:css, ".vue-slider-piecewise .vue-slider-piecewise-item #mid-range-#{mid_range_value}").trigger('click')
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(high_end_value.to_s)
            expect(page).to have_css('span.vue-slider-tooltip', visible: :all, text: high_end_value.to_s)
          end
        end
      end

      context 'sliding the slider' do
        # TODO: Fix Slider Value
        xit 'sets their input', js: true do
          within "#plan-product-category-#{plan_product_category.id}" do
            mid_range_value = plan_product_category.product_category.price_boundary(limit_type: :mid_range).limit
            source = first('.vue-slider-dot')
            target = page.find("#mid-range-#{mid_range_value}")
            source.drag_to(target)
            expect(page).to have_css('span.vue-slider-tooltip', visible: :all, text: mid_range_value.to_s)
            expect(find_field("order[plan_product_categories_attributes][1][budget]").value).to eq(mid_range_value.to_s)
          end
        end
      end
    end

    context 'has no special offers' do
      before do
        SpecialOffer.delete_all
        visit edit_enrollment_order_path(order)
      end

      it 'does not show the special offer inputs' do
        expect(page).to have_no_content t('enrollment.orders.form.special_offers')
        expect(page).to have_no_css('.special-offer')
      end
    end

    context 'has special offers' do
      it 'shows special offers' do
        expect(page).to have_content t('enrollment.orders.special_offers.special_offers')
        expect(page).to have_css('.special-offer')
        expect(page).to have_content special_offers(:one).name
        expect(page).to have_content special_offers(:one).description
        expect(page).to have_content special_offers(:two).name
        expect(page).to have_content special_offers(:two).description
      end

      it 'updates plan with selected special offers' do
        check id: special_offer_checkbox_id(special_offers(:one))
        check id: special_offer_checkbox_id(special_offers(:two))
        click_button I18n.t('helpers.submit.order.update')

        order.reload
        expect(order.special_offers.count).to eq 2
        expect(order.special_offers).to include(special_offers(:one), special_offers(:two))
      end

      it 'clears the previous selected special offers' do
        uncheck id: special_offer_checkbox_id(special_offers(:one))
        uncheck id: special_offer_checkbox_id(special_offers(:two))
        click_button I18n.t('helpers.submit.order.update')

        order.reload
        expect(order.special_offers.count).to be_zero
      end

      it 'can decline all special offers', js: true do
        check id: special_offer_checkbox_id(special_offers(:one))
        check id: special_offer_checkbox_id(special_offers(:two))
        check id: "decline_special_offers"
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:one))).disabled?).to eq true
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:one))).checked?).to eq false
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:two))).disabled?).to eq true
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:two))).checked?).to eq false
        click_button I18n.t('helpers.submit.order.update')

        order.reload
        expect(order.special_offers.count).to be_zero
      end
    end

    context 'user has already selected special offers' do
      before do
        order.special_offers << special_offers(:one)
        visit edit_enrollment_order_path(order)
      end

      it 'does not let the user update their selected special offers' do
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:one))).disabled?).to eq true
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:one))).checked?).to eq true
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:two))).disabled?).to eq true
        expect(find_special_offer_checkbox_by_id(special_offer_checkbox_id(special_offers(:two))).checked?).to eq false
        expect(find_special_offer_checkbox_by_id('decline_special_offers').disabled?).to eq true
        expect(find_special_offer_checkbox_by_id('decline_special_offers').checked?).to eq false
        expect(find_special_offer_checkbox_by_id('decline_special_offers').disabled?).to eq true
        expect { click_button(I18n.t('helpers.submit.order.update')) }.to_not change(order.special_offers, :count)
      end
    end

    context 'special offer has usage instructions', js: true do
      before do
        special_offers(:one).update usage_instructions: 'Insert coins to continue'
        visit edit_enrollment_order_path(order)
      end

      it 'shows the usage instructions title and anchor' do
        expect(page).to have_content t('enrollment.orders.special_offers.usage_instructions')
        expect(page).to have_css('.ri-tooltip', text: t('enrollment.orders.special_offers.usage_instructions_anchor'))
      end

      it 'has the tooltip invisible not on hover' do
        expect(page).to have_no_content special_offers(:one).usage_instructions
      end

      it 'has the tooltip visible on hover' do
        all('.ri-tooltip').last.hover
        expect(page).to have_content special_offers(:one).usage_instructions
      end
    end
  end

  describe 'navigation' do
    it 'goes back to the organization page' do
      expect(page).to have_link t('enrollment.back'), href: new_organization_enrollment_sign_up_path(organization), count: 1
    end
  end

  describe 'Redemption Instructions' do
    let(:product_category) { product_categories(:fashion) }
    let(:admin_user) { users(:admin) }
    let(:primary_user) { users(:joseph) }
    let(:broker_user) { users(:broker) }

    context 'for an admin user' do
      before do
        sign_in admin_user
      end

      context 'when organization has no redemption instructions' do
        before do
          product_category.update(redemption_instructions_editable: false)
          visit edit_enrollment_order_path(order)
        end

        it 'none are visible' do
          expect(page).to have_no_css('.ri-tooltip', text: t('enrollment.orders.form.redemption_requirements_anchor'))
        end
      end

      context 'when organization has redemption instructions', js: true do
        let(:old_instruction) { redemption_instructions(:fashion_instruction) }
        let(:new_instruction) { redemption_instructions(:fashion_instruction_two) }

        before do
          old_instruction.update(active: true)
          visit edit_enrollment_order_path(order)
        end

        it 'shows the redemption requirement and anchor' do
          expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements')
          expect(page).to have_css('.ri-tooltip', text: t('enrollment.orders.code_amount.redemption_requirements_anchor'))
        end

        it 'has the tooltip invisible not on hover' do
          within all('.redemption-instruction').first do
            expect(page).to have_no_content t('enrollment.orders.code_amount.redemption_requirements_info')
          end
        end

        it 'has the tooltip visible on hover' do
          within all('.redemption-instruction').first do
            find('.ri-tooltip').hover
            expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements_info')
          end
        end

        context 'adding a new instruction' do
          it 'leaves the previous instruction active if not selected' do
            select I18n.t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
            expect do
              within '#new-redemption-instruction-form' do
                fill_in 'redemption_instruction[title]', with: 'New title'
                fill_in 'redemption_instruction[description]', with: 'New description'
                find('input[name="commit"]').trigger('click')
              end
              expect(page).to have_no_selector('.modal-content')
            end.to change(RedemptionInstruction, :count).by(1)

            created_instruction = RedemptionInstruction.last.tap do |redemption_instruction|
              expect(redemption_instruction.title).to eq 'New title'
              expect(redemption_instruction.description).to eq 'New description'
              expect(redemption_instruction.organization).to eq organization
              expect(redemption_instruction.active).to be_falsy
              expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: redemption_instruction.title)
            end

            select old_instruction.title, from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'

            expect do
              find('input[name="commit"]').click
              expect(page.current_path).to eq(new_enrollment_order_member_path(order))
            end.to_not change { old_instruction.reload.active }

            expect(created_instruction.reload.active).to be_falsy
          end
        end
      end
    end

    context 'for an primary user' do
      before do
        sign_in primary_user
      end

      context 'when organization has no redemption instructions' do
        before do
          product_category.update(redemption_instructions_editable: false)
          visit edit_enrollment_order_path(order)
        end

        it 'none are visible' do
          expect(page).to have_no_css('.ri-tooltip', text: t('enrollment.orders.form.redemption_requirements_anchor'))
        end
      end

      context 'when organization has redemption instructions', js: true do
        let(:old_instruction) { redemption_instructions(:fashion_instruction) }
        let(:new_instruction) { redemption_instructions(:fashion_instruction_two) }

        before do
          old_instruction.update(active: true)
          visit edit_enrollment_order_path(order)
        end

        it 'shows the redemption requirement and anchor' do
          expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements')
          expect(page).to have_css('.ri-tooltip', text: t('enrollment.orders.code_amount.redemption_requirements_anchor'))
        end

        it 'has the tooltip invisible not on hover' do
          expect(page).to have_no_content t('enrollment.orders.code_amount.redemption_requirements_info')
        end

        it 'has the tooltip visible on hover' do
          within all('.redemption-instruction').first do
            find('.ri-tooltip').hover
          end
          expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements_info')
        end

        context 'adding a new instruction' do
          it 'leaves the previous instruction active if not selected' do
            select I18n.t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
            expect do
              within '#new-redemption-instruction-form' do
                fill_in 'redemption_instruction[title]', with: 'New title'
                fill_in 'redemption_instruction[description]', with: 'New description'
                find('input[name="commit"]').trigger('click')
              end
              expect(page).to have_no_selector('.modal-content')
            end.to change(RedemptionInstruction, :count).by(1)

            created_instruction = RedemptionInstruction.last.tap do |redemption_instruction|
              expect(redemption_instruction.title).to eq 'New title'
              expect(redemption_instruction.description).to eq 'New description'
              expect(redemption_instruction.organization).to eq organization
              expect(redemption_instruction.active).to be_falsy
              expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: redemption_instruction.title)
            end

            select old_instruction.title, from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'

            expect do
              find('input[name="commit"]').click
              expect(page.current_path).to eq(new_enrollment_order_member_path(order))
            end.to_not change { old_instruction.reload.active }

            expect(created_instruction.reload.active).to be_falsy
          end
        end
      end
    end

    context 'for an broker user' do
      before do
        sign_in broker_user
        broker_user.organizations << organization
      end

      context 'when organization has no redemption instructions' do
        before do
          product_category.update(redemption_instructions_editable: false)
          visit edit_enrollment_order_path(order)
        end

        it 'none are visible' do
          expect(page).to have_no_css('.ri-tooltip', text: t('enrollment.orders.form.redemption_requirements_anchor'))
        end
      end

      context 'when organization has redemption instructions', js: true do
        let(:old_instruction) { redemption_instructions(:fashion_instruction) }
        let(:new_instruction) { redemption_instructions(:fashion_instruction_two) }

        before do
          old_instruction.update(active: true)
          visit edit_enrollment_order_path(order)
        end

        it 'shows the redemption requirement and anchor' do
          expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements')
          expect(page).to have_css('.ri-tooltip', text: t('enrollment.orders.code_amount.redemption_requirements_anchor'))
        end

        it 'has the tooltip invisible not on hover' do
          within all('.redemption-instruction').first do
            expect(page).to have_no_content t('enrollment.orders.code_amount.redemption_requirements_info')
          end
        end

        it 'has the tooltip visible on hover' do
          within all('.redemption-instruction').first do
            find('.ri-tooltip').hover
            expect(page).to have_content t('enrollment.orders.code_amount.redemption_requirements_info')
          end
        end

        context 'adding a new instruction' do
          it 'leaves the previous instruction active if not selected' do
            select I18n.t('helpers.new_redemption_instruction'), from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'
            expect do
              within '#new-redemption-instruction-form' do
                fill_in 'redemption_instruction[title]', with: 'New title'
                fill_in 'redemption_instruction[description]', with: 'New description'
                find('input[name="commit"]').trigger('click')
              end
              expect(page).to have_no_selector('.modal-content')
            end.to change(RedemptionInstruction, :count).by(1)

            created_instruction = RedemptionInstruction.last.tap do |redemption_instruction|
              expect(redemption_instruction.title).to eq 'New title'
              expect(redemption_instruction.description).to eq 'New description'
              expect(redemption_instruction.organization).to eq organization
              expect(redemption_instruction.active).to be_falsy
              expect(page).to have_select('order[plan_product_categories_attributes][1][redemption_instruction][instruction]', selected: redemption_instruction.title)
            end

            select old_instruction.title, from: 'order[plan_product_categories_attributes][1][redemption_instruction][instruction]'

            expect do
              find('input[name="commit"]').click
              expect(page.current_path).to eq(new_enrollment_order_member_path(order))
            end.to_not change { old_instruction.reload.active }

            expect(created_instruction.reload.active).to be_falsy
          end
        end
      end
    end
  end

  def fill_out_form
    date = Date.current
    fill_in 'order[starts_on]', with: format_date(date)
  end

  def format_date(date)
    I18n.l(date.to_date, format: :mmddyyyy)
  end

  def special_offer_checkbox_id(special_offer)
    "order_special_offer_ids_#{special_offer.id}"
  end

  def find_special_offer_checkbox_by_id(id)
    find(:css, "input##{id}")
  end
end
