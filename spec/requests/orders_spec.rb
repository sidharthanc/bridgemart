describe 'Orders', type: :request do
  let(:order) { orders(:metova) }
  let(:unpaid_order) { orders(:metova_unpaid) }
  let(:organization) { organizations(:metova) }
  as { users(:joseph) }

  describe 'index' do
    before do
      visit organization_orders_path(organization)
    end

    describe 'nav header' do
      it 'has a link to the orders page' do
        expect(page).to have_link t('layouts.dashboard.nav.billing'), href: organization_orders_path(organization)
      end

      it 'has a link to the payment methods page' do
        expect(page).to have_link t('layouts.dashboard.nav.payment_methods'), href: organization_payment_methods_path(organization)
      end
    end

    context 'legacy order' do
      it 'does not show legacy on orders originated on this app' do
        expect(page).to have_no_content t('orders.order_header.legacy')
      end

      it 'shows legacy on imported orders' do
        order.update legacy_identifier: 123_456
        order.line_items << LineItem.new(order: order, charge_type: :charge, amount: 1200.to_money, quantity: 4)
        order.line_items << LineItem.new(order: order, charge_type: :fee, amount: 108.to_money, quantity: 4)
        visit organization_orders_path(organization)
        expect(page).to have_content t('orders.order_header.legacy')
      end
    end

    describe 'status card' do
      it 'shows organization billing status data' do
        within '.status-container' do
          expect(page).to have_content organization.members_count
          expect(page).to have_content I18n.t("organizations.statuses.#{organization.account_status}")
          expect(page).to have_content I18n.l(organization.orders.first.starts_on, format: :mmddyyyy)
          expect(page).to have_content I18n.l(organization.created_at, format: :mmddyyyy)
          expect(page).to have_content organization.ytd_load.format
          expect(page).to have_content organization.lifetime_load.format
        end
      end
    end

    it 'shows a table row with order information' do
      organization.orders.has_members.all.each do |order|
        expect(page).to have_content order.po_number
        expect(page).to have_content order.status
        expect(page).to have_content I18n.l(order.created_at, format: :mmddyyyy)
        expect(page).to have_content order.formatted_total
      end
    end

    it 'has a view link for each order paid' do
      organization.orders.all.each do |order|
        expect(page).to have_link(I18n.t('orders.index.actions.view'), href: organization_order_path(organization, order)) if order.paid?
      end
    end

    it 'has an edit link if the order is not paid' do
      organization.orders.all.each do |order|
        expect(page).to have_no_link(I18n.t('orders.index.actions.view'), href: organization_order_path(organization, order)) unless order.paid?
      end
    end

    describe 'csv exports' do
      it 'downloads a csv for orders' do
        expect(page).to have_link I18n.t('orders.index.export'), href: organization_orders_path(organization, format: :csv)
        click_link I18n.t('orders.index.export')
      end
    end

    context 'advanced search' do
      let(:order1) { orders(:metova) }
      let!(:order2) { Order.create!(starts_on: Date.today, ends_on: (Date.today + 1.year), created_at: 1.day.ago, plan: plans(:metova)) }

      before do
        order2.members << organization.members.last
        visit new_organization_advanced_search_orders_path(organization)
      end

      it 'filters the list of orders by id' do
        visit organization_orders_path(organization)
        expect(page).to have_content order1.id
        expect(page).to have_content order2.id
        visit new_organization_advanced_search_orders_path(organization)

        fill_in 'q_id_cont', with: order.id
        click_button t('helpers.search.apply_filter')

        expect(page).to have_content order1.id
        expect(page).not_to have_content order2.id
      end

      it 'filers the list of orders by due date' do
        fill_in 'q_created_at_gteq', with: l(Date.current, format: :mmddyyyy)
        fill_in 'q_created_at_lteq', with: l(Date.tomorrow, format: :mmddyyyy)
        click_button t('helpers.search.apply_filter')

        expect(page).to have_content order1.id
        expect(page).not_to have_content order2.id
      end

      it 'filers the list of orders by status' do
        select 'Paid', from: 'q_status_in'
        click_button t('helpers.search.apply_filter')

        expect(page).not_to have_content order2.id
        expect(page).to have_content order1.id
      end

      context 'with browser refresh' do
        before do
          fill_in 'q_id_cont', with: order1.id
          click_button t('helpers.search.apply_filter')
        end

        it 'navigates to the orders index, filtered' do
          expect(page.current_path).to eq search_organization_orders_path(organization)
          expect(page).not_to have_content order2.id
        end

        it 'navigates to the orders index, unfiltered' do
          visit current_path
          expect(page.current_path).to eq organization_orders_search_path(organization)
          expect(page).to have_content order2.id
        end
      end
    end
  end
end
