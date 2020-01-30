describe 'Credit Purchase Void', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:credit_purchase) { credit_purchases(:unpaid) }

  before do
    visit organization_credit_purchases_path(organization)
  end

  it 'voids the credit purchase' do
    within("#credit_purchase_#{credit_purchase.id}") do
      expect(credit_purchase).not_to be_voided
      click_link t(:void)
      expect(credit_purchase.reload).to be_voided
    end
  end
end
