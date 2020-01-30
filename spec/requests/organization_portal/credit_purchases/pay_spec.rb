describe 'Credit Purchase Pay', type: :request do
  as { users(:andrew) }
  let(:organization) { organizations(:metova) }
  let(:credit_purchase) { credit_purchases(:unpaid) }

  context 'PaymentService capture' do
    it 'is a good payment' do
      allow(CardConnect::Service::Authorization).to receive(:new)
        .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))

      expect(credit_purchase).not_to be_paid
      expect do
        patch organization_credit_purchase_pay_path(organization, credit_purchase)
      end.to change(Credit, :count).by(1)
      expect(credit_purchase.reload).to be_paid
      expect(credit_purchase.error_message).to be_blank
    end

    it 'is a bad payment' do
      allow(CardConnect::Service::Authorization).to receive(:new)
        .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :failure))

      expect(credit_purchase).not_to be_paid
      expect(credit_purchase.error_message).to be_blank
      expect do
        patch organization_credit_purchase_pay_path(organization, credit_purchase)
      end.not_to change(Credit, :count)
      expect(credit_purchase.reload).not_to be_paid
      expect(credit_purchase.error_message).to be_present
    end

    it 'is a good payment after fixing from being bad' do
      allow(CardConnect::Service::Authorization).to receive(:new)
        .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))

      credit_purchase.update error_message: 'Duplicate transaction REFID:1186459787'

      expect(credit_purchase).not_to be_paid
      expect do
        patch organization_credit_purchase_pay_path(organization, credit_purchase)
      end.to change(Credit, :count).by(1)
      expect(credit_purchase.reload).to be_paid
      expect(credit_purchase.error_message).to be_blank
    end
  end
end
