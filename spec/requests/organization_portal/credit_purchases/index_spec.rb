describe 'Credit Purchases', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:paid_credit_purchase) { credit_purchases(:metova) }
  let(:unpaid_credit_purchase) { credit_purchases(:unpaid) }
  let(:void_credit_purchase) { credit_purchases(:voided) }

  before do
    visit organization_credit_purchases_path(organization)
  end

  context 'CSV for existing credit purchases' do
    let(:subject) { unpaid_credit_purchase }

    it 'downloads a Credit Purchase CSV' do
      click_on t('organization_portal.credit_purchases.index.export')

      page.response_headers['Content-Disposition'].tap do |header|
        expect(header).to match /^attachment/
        expect(header).to match /filename="credit-purchases-#{Date.current}.csv"$/
      end
    end
  end

  it 'No CSV button when there are no credit purchases' do
    CreditPurchase.delete_all

    visit organization_credit_purchases_path(organization)
    expect(page).not_to have_link t('organization_portal.credit_purchases.index.export')
  end

  it 'shows the purchase credit button on the Organization Portal Credit page' do
    visit organization_credits_path(organization)
    expect(page).to have_link t('organization_portal.credits.index.purchase_credits'), href: organization_credit_purchases_path(organization)
  end

  context 'Credit Purchase Index' do
    it 'shows unpaid/paid/voided credit purchases' do
      expect(page).to have_content unpaid_credit_purchase.po_number
      expect(page).to have_content paid_credit_purchase.po_number
      expect(page).to have_content void_credit_purchase.po_number
    end

    it 'shows the New Credit Purchase button' do
      expect(page).to have_link t('organization_portal.credit_purchases.index.buttons.new'), href: new_organization_credit_purchase_path(organization)
    end
  end

  context 'unpaid credit purchases' do
    let(:subject) { unpaid_credit_purchase }

    it 'can be edited, voided, paid, and printed' do
      within("#credit_purchase_#{subject.id}") do
        expect(page).to have_link t(:edit), href: edit_organization_credit_purchase_path(organization, subject)
        expect(page).to have_link t(:void), href: organization_credit_purchase_void_path(organization, subject)
        expect(page).to have_link t(:pay), href: organization_credit_purchase_pay_path(organization, subject)
        expect(page).to have_link t(:print), href: organization_credit_purchase_print_path(organization, subject)
      end
    end
  end

  context 'paid credit purchases' do
    let(:subject) { paid_credit_purchase }

    it 'cannot be edited, voided, or paid' do
      within("#credit_purchase_#{subject.id}") do
        expect(page).to have_no_link t(:edit), href: edit_organization_credit_purchase_path(organization, subject)
        expect(page).to have_no_link t(:void), href: organization_credit_purchase_void_path(organization, subject)
        expect(page).to have_no_link t(:pay), href: organization_credit_purchase_pay_path(organization, subject)
        expect(page).to have_link t(:print), href: organization_credit_purchase_print_path(organization, subject)
      end
    end

    it 'can be printed' do
      within("#credit_purchase_#{subject.id}") do
        expect(page).to have_link t(:print), href: organization_credit_purchase_print_path(organization, subject)
      end
    end
  end

  context 'voided credit purchases' do
    let(:subject) { void_credit_purchase }

    it 'cannot be edited, voided, or paid' do
      within("#credit_purchase_#{subject.id}") do
        expect(page).to have_no_link t(:edit), href: edit_organization_credit_purchase_path(organization, subject)
        expect(page).to have_no_link t(:void), href: organization_credit_purchase_void_path(organization, subject)
        expect(page).to have_no_link t(:pay), href: organization_credit_purchase_pay_path(organization, subject)
        expect(page).to have_link t(:print), href: organization_credit_purchase_print_path(organization, subject)
      end
    end

    it 'can be printed' do
      within("#credit_purchase_#{subject.id}") do
        expect(page).to have_link t(:print), href: organization_credit_purchase_print_path(organization, subject)
      end
    end
  end
end
