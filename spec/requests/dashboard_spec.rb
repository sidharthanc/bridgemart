describe 'Dashboard', type: :request do
  let(:user) { users(:joseph) }
  let(:admin) { users(:andrew) }
  let(:organization) { organizations(:metova) }
  as { user }

  before do
    attach_images_to_product_categories
    visit dashboard_path
  end

  it 'shows a sign out link' do
    expect(page).to have_link I18n.t('shared.user_controls.sign_out')
  end

  it 'shows the new order link' do
    expect(page).to have_link I18n.t('shared.user_controls.new_order')
  end

  it 'has a registrations edit link' do
    expect(page).to have_link user.email, href: edit_user_registration_path
  end

  describe 'credits total' do
    context 'no credits' do
      it 'does not show the available credits line' do
        expect(page).not_to have_content I18n.t('pages.dashboard.credits_available')
      end
    end

    context 'with credits' do
      before do
        organization.credit_pool amount: 200, source: organization
        visit dashboard_path
      end

      it 'shows me how many credits I have remaining' do
        expect(page).to have_content organization.credit_total.format
        expect(page).to have_content I18n.t('pages.dashboard.credits_available')
      end
    end
  end

  describe 'admin link' do
    context 'as an admin' do
      as { admin }

      before { visit organizations_path }

      it 'shows the admin link' do
        expect(page).to have_link I18n.t('layouts.dashboard.nav.admin')
      end
    end

    context 'as a non admin' do
      as { user }

      before { visit organizations_path }

      it 'does not show the admin link' do
        expect(page).to_not have_link I18n.t('layouts.dashboard.nav.admin')
      end
    end
  end

  it 'is linked to on the sidebar' do
    visit root_path
    within '.dashboard-nav' do
      expect(page).to have_link 'Dashboard', href: dashboard_path(organization_id: organization.id)
    end
  end

  it 'has a locator link on the sidebar' do
    visit root_path
    within '.dashboard-nav' do
      expect(page).to have_link I18n.t('layouts.dashboard.nav.locator'), href: settings(:external_locator_url).value
    end
  end

  it 'does not have an organizations link on the sidebar' do
    visit root_path
    within '.dashboard-nav' do
      expect(page).to_not have_link I18n.t('layouts.dashboard.nav.organizations'), href: organizations_path
    end
  end

  context 'as a broker' do
    before { user.permission_groups = [permission_groups(:broker)] }

    it 'the root path is the overview' do
      visit root_path
      expect(current_path).to eq(organizations_path)
    end

    it 'has an organizations link on the dashboard sidebar' do
      visit dashboard_path(organization_id: organization.id)
      within '.dashboard-nav' do
        expect(page).to have_link I18n.t('layouts.dashboard.nav.organizations'), href: organizations_path
      end
    end
  end

  context 'as an admin' do
    before { user.permission_groups = [permission_groups(:admin)] }

    it 'the root path is the overview' do
      visit root_path
      expect(current_path).to eq(organizations_path)
    end

    it 'has an organizations link on the dashboard sidebar' do
      visit dashboard_path(organization_id: organization.id)
      within '.dashboard-nav' do
        expect(page).to have_link I18n.t('layouts.dashboard.nav.organizations'), href: organizations_path
      end
    end
  end

  context 'with an incomplete enrollment' do
    context 'with no current plan' do
      let(:user) { users(:test) }

      it 'prompts to complete enrollment' do
        expect(page.current_path).to eq new_enrollment_sign_up_path
      end
    end
  end

  # Budget Card is disabled in the Application Currently
  xdescribe 'Budget Card', js: true do
    let(:card) { '.budget-card-container' }

    it 'shows the total budget amount' do
      within card do
        expect(page).to have_content I18n.t('pages.dashboard.budget.title')
        expect(page).to have_content I18n.t('pages.dashboard.budget.total', amount: '')
      end
    end

    it 'shows a legend for the product type graph' do
      within card do
        expect(page).to have_content '$180'
        expect(page).to have_content '$435'
        expect(page).to have_content '$270'
        organization.plan_product_categories.each do |ppc|
          expect(page).to have_content ppc.name, count: 1
        end

        expect(page).to have_content t('pages.dashboard.budget.remaining')
        expect(page).to have_content '$685'
      end
    end

    context 'with multiple like categories' do
      before do
        organization.plan_product_categories.map(&:dup).each(&:save)
        visit dashboard_path
      end

      it 'consolidates the values into one calculated total' do
        within card do
          expect(page).to have_content '$360'
          expect(page).to have_content '$870'
          expect(page).to have_content '$540'
          organization.reload.plan_product_categories.each do |ppc|
            expect(page).to have_content ppc.name, count: 1
          end

          expect(page).to have_content t('pages.dashboard.budget.remaining')
          expect(page).to have_content '$1,570'
        end
      end
    end
  end

  # Products Card is disabled in the Application Currently
  xdescribe 'Products Card' do
    let(:order) { orders(:metova) }
    let(:card) { '.products-card-container' }
    let(:selected_category) { plan_product_categories(:exam) }

    it 'has a card for product information' do
      within card do
        expect(page).to have_content I18n.t('pages.dashboard.products.title')
        expect(page).to have_content(
          I18n.t('pages.dashboard.products.starts_on', date: I18n.l(order.starts_on, format: :long))
        )
      end
    end

    it 'shows each product category' do
      within card do
        expect(page).to have_content selected_category.name
        expect(page).to have_content selected_category.description
      end
    end

    it 'links to the product details CRUD page' do
      within card do
        expect(page).to have_link I18n.t('pages.dashboard.products.edit'), href: edit_enrollment_order_path(order)
      end
    end

    it 'does not link to the product details CRUD page if the plan is ongoing' do
      plan.update starts_on: 1.hour.ago
      visit dashboard_path

      within card do
        expect(page).to_not have_link I18n.t('pages.dashboard.products.edit')
      end
    end
  end

  # Members Card is disabled in the Application Currently
  xdescribe 'Members Card' do
    let(:plan) { plans(:metova) }
    let(:card) { '#members-card' }

    it 'has an usage overall' do
      travel_to Time.zone.local(2018, 12, 31, 7, 0, 0) do
        organization.orders.first.update! starts_on: 10.days.ago

        visit dashboard_path

        within card do
          expect(page).to have_content t('pages.dashboard.members.overall_usage')
          expect(page).to have_content t('pages.dashboard.members.overall_ytd')
          expect(page).to have_content t('pages.dashboard.members.used_funds', used: organization.usage_percentage_ytd)
          expect(page).to have_content t('pages.dashboard.members.average_days', average_days: 10)
        end
      end
    end

    it 'has a card that shows the member usage', js: true do
      within card do
        expect(page).to have_content t('pages.dashboard.members.count', count: 1)
        expect(page).to have_content t('pages.dashboard.members.have_usage', count: 1)
        expect(page).to have_content t('pages.dashboard.members.count', count: 2)
        expect(page).to have_content t('pages.dashboard.members.have_no_usage', count: 2)
        expect(page).to have_selector '.chart-container'
      end
    end
  end

  # Customer Card is disabled in the Application Currently
  xdescribe 'Customer Card Load', js: true do
    let(:plan) { plans(:metova) }
    let(:card) { '#transactions-card' }
    let(:code) { codes(:logan) }

    it 'shows a graph of transactions' do
      within card do
        expect(page).to have_selector '.transactions-chart'
        expect(page).to have_selector '.stacked-area-legend'
      end
    end

    it 'plots an area for each type of transaction' do
      code.usages.create amount: 100, used_at: Date.current
      visit dashboard_path
      within card do
        expect(page).to have_selector '.transactions-chart .layer'
        expect(page).to have_content code.product_category.division.name.gsub('Bridge ', '')
      end
    end
  end

  describe 'Billing' do
    let(:order) { orders(:metova) }
    it 'should show billing table headers' do
      expect(page).to have_content I18n.t('orders.index.columns.id')
      expect(page).to have_content I18n.t('orders.index.columns.order_date')
      expect(page).to have_content I18n.t('orders.status')
      expect(page).to have_content I18n.t('orders.amount')
    end
    it 'should show view all link' do
      expect(page).to have_link I18n.t('orders.view_all')
    end
    it 'should show an order, when order is generated' do
      expect(page).to have_content(order.id)
      expect(page).to have_content(l(order.starts_on, format: :mmddyyyy))
    end
  end
end
