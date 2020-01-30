RSpec.describe PaymentMethodsController, type: :controller do
  let(:user) { users(:joseph) }
  let(:payment_method) { payment_methods(:credit) }
  let(:organization) { organizations(:metova) }

  before do
    sign_in user
  end

  describe 'GET confirm' do
    context 'valid data returned' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))
      end

      it 'redirects to the index page on success' do
        expect(get(:confirm, params: { organization_id: organization.id, id: payment_method.id })).to redirect_to organization_payment_methods_path(organization)
      end

      xit "updates the billing contact and addresses for the payment method" do
        pending "This needs implementation" # TODO: use authorize response to update billing information
        expect do
          get :confirm, params: { organization_id: organization.id, id: payment_method.id }
        end.to change(Address, :count).by 0

        expect do
          get :confirm, params: { organization_id: organization.id, id: payment_method.id }
        end.to change(BillingContact, :count).by 0

        payment_method.billing_contact.reload
        payment_method.billing_contact.tap do |billing_contact|
          expect(billing_contact.first_name).to eq 'Firstname'
          expect(billing_contact.last_name).to eq 'McLastname'
          expect(billing_contact.email).to eq 'test@example.com'
        end

        payment_method.address.reload
        payment_method.address.tap do |address|
          expect(address.street1).to eq '123 Test St.'
          expect(address.street2).to eq 'Apt 102'
          expect(address.city).to eq 'Maumelle'
          expect(address.state).to eq 'AR'
          expect(address.zip).to eq '72113'
        end
      end
    end

    context 'error returned' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :failure))
      end

      it "redirects to the edit payment method path" do
        expect(get(:confirm, params: { organization_id: organization.id, id: payment_method.id })).to redirect_to edit_organization_payment_method_path(organization, payment_method)
        expect(controller).to set_flash[:alert]
      end
    end
  end
end
