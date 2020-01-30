RSpec.describe Enrollment::PaymentsController, type: :controller do
  include ActiveJob::TestHelper

  let(:user) { users(:test) }
  let(:order) { orders(:metova) }
  let(:invalid_order) { orders(:bridge) }
  let(:unpaid_order) { orders(:metova_unpaid) }
  let(:credit_card) { payment_methods(:credit) }

  before do
    OrganizationUser.create(organization: order.organization, user: user)
    sign_in user
  end

  after do
    clear_enqueued_jobs
  end

  describe 'GET confirm' do
    it "it doesn't allow unauthorized order access" do
      expect do
        get :confirm, params: { order_id: invalid_order.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'PaymentService has successfully processed the payment' do
      it 'redirects us to the dashboard' do
        order.update(processed_at: DateTime.current, paid_at: DateTime.current)
        expect(get(:confirm, params: { order_id: order.id })).to redirect_to dashboard_path
      end
    end

    context 'we are still processing the request' do
      it 'redirects us to the processing page, so we can watch our progress' do
        expect(get(:confirm, params: { order_id: order.id })).to redirect_to process_order_enrollment_order_payments_path(order)
      end
    end

    context 'PaymentService has returned an error, or the payment was otherwise not processed' do
      it 'redirects us to the enrollment payment page' do
        unpaid_order.update(processed_at: DateTime.current, paid_at: nil, error_message: "An error occured")
        expect(get(:confirm, params: { order_id: unpaid_order.id })).to redirect_to new_enrollment_order_payment_path(unpaid_order)
      end
    end
  end

  describe 'GET process_order' do
    it "it doesn't allow unauthorized order access" do
      expect do
        get :process_order, params: { order_id: invalid_order.id, 'token-id' => '8675309' }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'PaymentService has returned to the page, and we want to start processing the payment' do
      it 'does not fire the job when a json request is made after' do
        expect(PaymentJob).to receive(:perform_later).never
        get :process_order, params: { order_id: unpaid_order.id, 'token-id' => '8675309' }
        get :process_order, format: :json, params: { order_id: unpaid_order.id, 'token-id' => '8675309' }
      end
    end

    context 'We have arrived here without a token' do
      # TODO: token validation
      xit 'redirects us to the enrollment payment page' do
        expect(get(:process_order, params: { order_id: unpaid_order.id })).to redirect_to new_enrollment_order_payment_path(unpaid_order)
      end
    end
  end
  describe 'POST create' do
    context 'Fully credited' do
      before do
        expect(@controller).to receive(:purchase_is_entirely_accrued_credit?).and_return true
      end
      it 'should run the Payment Job' do
        expect(PaymentJob).to receive(:perform_later)
        post :create, params: { order_id: order.id, payment: {} }
      end
    end
    context 'Requires payment' do
      xit do
        expect(PaymentJob).to receive(:perform_later).once
        post :create, params: { order_id: order.id, payment: {} }
      end
    end
  end
end
