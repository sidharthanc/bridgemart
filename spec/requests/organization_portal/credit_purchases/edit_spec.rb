describe 'Credit Purchase Edit', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:payment_method) { payment_methods(:ach) }
  let(:credit_purchase) { credit_purchases(:unpaid) }
  let(:po_number) { 'DIFF PO NUMBER' }
  let(:amount) { 543.21 }

  before do
    visit edit_organization_credit_purchase_path(organization, credit_purchase)
  end

  it 'lets the user edit the credit purchase' do
    expect(credit_purchase.payment_method).not_to eq payment_method

    fill_form

    expect { click_submit }.not_to change(CreditPurchase, :count)

    expect(page).to have_no_content "Amount #{t('activerecord.errors.models.credit_purchase.attributes.amount')}"

    credit_purchase.reload
    expect(credit_purchase.po_number).to eq po_number
    expect(credit_purchase.amount).to eq amount.to_money
    expect(credit_purchase.payment_method).to eq payment_method
  end

  it 'displays an error when amount < 1' do
    fill_in 'credit_purchase[amount]', with: 0

    expect { click_submit }.not_to change(CreditPurchase, :count)
    expect(page).to have_content "Amount #{t('activerecord.errors.models.credit_purchase.attributes.amount')}"
  end

  private
    def fill_form
      fill_in 'credit_purchase[po_number]', with: po_number
      fill_in 'credit_purchase[amount]', with: amount.to_s
      select organization.payment_methods.last.payment_card_number, from: 'credit_purchase[payment_method_id]'
    end

    def click_submit
      find('input[type=submit]').click
    end
end
