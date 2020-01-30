describe 'Credit Purchase New', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:payment_method) { organization.payment_methods.last }
  let(:new_credit_purchase) { CreditPurchase.new(po_number: 'M2018081012127', amount: 123.45, payment_method: payment_method) }

  before do
    visit new_organization_credit_purchase_path(organization)
  end

  it 'lets the user enter a new credit purchase' do
    fill_form

    expect { click_submit }.to change(CreditPurchase, :count).by(1)

    expect(page).to have_no_content "Amount #{t('activerecord.errors.models.credit_purchase.attributes.amount')}"

    credit_purchase = CreditPurchase.last
    expect(credit_purchase.po_number).to eq new_credit_purchase.po_number
    expect(credit_purchase.amount).to eq new_credit_purchase.amount
    expect(credit_purchase.payment_method).to eq new_credit_purchase.payment_method
  end

  it 'displays an error when amount < 1' do
    fill_in 'credit_purchase[amount]', with: 0

    expect { click_submit }.not_to change(CreditPurchase, :count)
    expect(page).to have_content "Amount #{t('activerecord.errors.models.credit_purchase.attributes.amount')}"
  end

  private
    def fill_form
      fill_in 'credit_purchase[po_number]', with: new_credit_purchase.po_number
      fill_in 'credit_purchase[amount]', with: new_credit_purchase.amount.to_s
      select organization.payment_methods.last.payment_card_number, from: 'credit_purchase[payment_method_id]'
    end

    def click_submit
      find('input[type=submit]').click
    end
end
