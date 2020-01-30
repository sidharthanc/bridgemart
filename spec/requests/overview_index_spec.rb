describe 'Overview Index', type: :request do
  let(:admin) { users(:andrew) }
  let(:broker) { users(:broker) }
  let(:user) { users(:joseph) }
  let(:organization) { organizations(:metova) }

  context 'login redirects' do
    it 'as an admin user' do
      login_as admin
      visit overview_index_path
      expect(current_path).to eq organizations_path
    end

    context 'as a broker user' do
      as { broker }

      it 'with no organizations' do
        visit overview_index_path

        expect(current_path).to eq organizations_path
      end

      it 'with existing organizations' do
        broker.organizations << organization
        visit overview_index_path

        expect(current_path).to eq organizations_path
      end
    end

    it 'as a normal user' do
      login_as user
      visit overview_index_path
      expect(current_path).to eq dashboard_path
    end
  end

  context 'Contents of Overview' do
    as { admin }

    before do
      attach_images_to_product_categories
      visit dashboard_path(organization_id: organization.id)
    end

    it 'shows a sign out link' do
      expect(page).to have_link I18n.t('shared.user_controls.sign_out')
    end

    context 'credits total' do
      context 'with credits' do
        before do
          organization.credit_pool amount: 200, source: organization
          visit dashboard_path(organization_id: organization.id)
        end

        it 'shows me how many credits I have remaining' do
          expect(page).to have_content organization.credit_total.format
          expect(page).to have_content I18n.t('overview.index.credits_available')
        end
      end
    end

    # Budget Card is currently disabled in the application
    context 'Budget Card', js: true, broken: true do
      let(:card) { '.budget-card-container' }

      it 'shows the total budget amount' do
        within card do
          expect(page).to have_content I18n.t('overview.index.budget.title')
          expect(page).to have_content I18n.t('overview.index.budget.total', amount: '')
        end
      end

      it 'shows a legend for the product type graph' do
        within card do
          expect(page).to have_content '$270'
          expect(page).to have_content '$435'
          expect(page).to have_content '$180'
          organization.plan_product_categories.each do |ppc|
            expect(page).to have_content ppc.name, count: 1
          end

          expect(page).to have_content t('overview.budget.remaining')
          expect(page).to have_content '$685'
        end
      end

      context 'with multiple like categories' do
        before do
          organization.plan_product_categories.map(&:dup).each(&:save)
          visit overview_index_path
        end
      end
    end

    # Members Card is currently disabled in the application
    context 'Members Card', broken: true do
      let(:plan) { plans(:metova) }
      let(:card) { '#members-card' }

      it 'has an usage overall' do
        travel_to Time.zone.local(2018, 12, 31, 7, 0, 0) do
          organization.orders.first.update! starts_on: 10.days.ago
          visit overview_index_path

          within card do
            expect(page).to have_content t('members.overall_usage')
            expect(page).to have_content t('members.overall_ytd')
            expect(page).to have_content t('members.used_funds', used: 22.6)
            expect(page).to have_content t('members.average_days', average_days: 10)
          end
        end
      end

      it 'has a card that shows the member usage', js: true do
        within card do
          expect(page).to have_content t('members.count', count: 1)
          expect(page).to have_content t('members.have_usage', count: 1)
          expect(page).to have_content t('members.count', count: 2)
          expect(page).to have_content t('members.have_no_usage', count: 2)
          expect(page).to have_selector '.chart-container'
        end
      end
    end

    # Customer Card Load is currently disabled in the application
    context 'Customer Card Load', js: true, broken: true do
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
        visit overview_index_path
        within card do
          expect(page).to have_selector '.transactions-chart .layer'
          expect(page).to have_content code.product_category.division.name.gsub('Bridge ', '')
        end
      end
    end
  end
end
