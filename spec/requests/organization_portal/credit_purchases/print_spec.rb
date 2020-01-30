describe 'Credit Purchase Print', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:credit_purchase) { credit_purchases(:metova) }

  it 'prints the credit purchase invoice' do
    visit organization_credit_purchases_path(organization)

    within("#credit_purchase_#{credit_purchase.id}") do
      click_link t(:print)
    end

    expect(page).to have_content t('organization_portal.credit_purchases.print.invoice.header')
  end
end
