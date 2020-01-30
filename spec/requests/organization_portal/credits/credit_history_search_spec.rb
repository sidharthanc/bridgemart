describe 'Credit history search features', type: :request do
  as { users(:joseph) }
  let(:organization) { organizations(:metova) }
  let(:code) { codes(:logan) }

  let!(:credit_1) { organization.credits.create(source: code, amount_cents: 1000, created_at: 8.days.ago) }
  let!(:credit_2) { organization.credits.create(source: organization, amount_cents: 1000, created_at: 6.days.ago) }
  let!(:credit_3) { organization.credits.create(source: organization, amount_cents: 1000, created_at: 4.days.ago) }
  let!(:credit_4) { organization.credits.create(source: organization, amount_cents: 1000, created_at: 2.days.ago) }

  before do
    visit edit_organization_organization_path(organization)
    click_link t('layouts.organization_portal.nav.credits')
  end

  context 'simple search' do
    it 'shows the credit history that matches our search terms' do
      fill_and_search(code.card_number)
      within '.credit-history__table' do
        expect(page).not_to have_content credit_2.source.id
        expect(page).not_to have_content credit_3.source.id
        expect(page).not_to have_content credit_4.source.id

        expect(page).to have_content credit_1.source.id
      end
    end
  end

  context 'advanced search' do
    before do
      click_on t('helpers.search.advanced')
    end

    it 'shows credits in the selected date range' do
      fill_in 'q_created_at_gteq', with: credit_2.created_at
      fill_in 'q_created_at_lteq', with: credit_3.created_at
      click_on 'credit-search'

      within '.credit-history__table' do
        expect(page).not_to have_content credit_1.created_at
        expect(page).not_to have_content credit_4.created_at

        expect(page).to have_content credit_2.created_at
        expect(page).to have_content credit_3.created_at
      end
    end
  end

  private
    def fill_and_search(search)
      fill_in 'q_credit_cont', with: search
      click_on 'credit-search'
    end
end
