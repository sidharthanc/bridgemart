describe 'Credits history (index) page', type: :request do
  as { users(:joseph) }
  let(:organization) { organizations(:metova) }
  let(:other_location) { locations(:other) }

  before do
    visit edit_organization_organization_path(organization)
  end

  it 'is linked to on the nav bar in the header' do
    expect(page).to have_link t('layouts.organization_portal.nav.credits'), href: organization_credits_path(organization)
  end

  context 'no locations' do
    before do
      visit organization_credits_path(organization)
    end

    it 'should not show the edit form' do
      expect(page).to have_no_selector '.edit_organization'
    end
  end

  context 'show credits', js: true do
    before do
      organization.credit_pool amount: 200, source: organization
      click_link t('layouts.organization_portal.nav.credits')
    end

    it 'shows organization credits' do
      expect(page).to have_content t('organization_portal.credits.index.header')
      expect(page).to have_content humanized_money_with_symbol organization.credit_total
    end

    it 'shows the credit history', broken: true do
      within '.credit-history__table' do
        expect(page).to have_content organization.credits.last.created_at
        expect(page).to have_content organization.credits.last.source.id
        expect(page).to have_content organization.credits.last.amount.format
        expect(page).to have_content organization.remaining_balance_at(organization.credits.last).format
      end
    end
  end

  context 'CSV for existing credit' do
    it 'downloads a Credit CSV' do
      organization.credit_pool amount: 200, source: organization
      visit organization_credits_path(organization)
      click_on t('organization_portal.credits.index.export')

      page.response_headers['Content-Disposition'].tap do |header|
        expect(header).to match /^attachment/
        expect(header).to match /filename="credit-#{Date.current}.csv"$/
      end
    end

    it 'No CSV button when there are no credit' do
      visit organization_credits_path(organization)

      expect(page).not_to have_link t('organization_portal.credits.index.export')
    end
  end
end
