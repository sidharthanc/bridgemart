describe PaymentService do
  describe '.credentials' do
    it do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      expect(described_class.credentials).to eq Rails.application.credentials.dig(:production, :cardconnect)
    end
  end

  describe '#authorize' do
    context 'successful' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))
      end
      context "with capture" do
        context "credit_card" do
          let(:order) { orders(:metova) }
          before do
            order.payment_method = payment_methods(:credit)
            expect(order.total_with_credits).to be >= 900.to_money
          end

          subject { PaymentService.authorize(order.payment_method, amount: order.total_with_credits, capture: true) }
          it { is_expected.to be_success }
        end
        context "with ACH" do
          let(:order) { orders(:metova) }
          before do
            order.payment_method = payment_methods(:ach)
            expect(order.total_with_credits).to be >= 900.to_money
          end

          subject { PaymentService.authorize(order.payment_method, amount: order.total_with_credits, capture: true) }
          it { is_expected.to be_success }
        end
      end
    end

    context "unsuccessful" do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :failure))
      end
      context "credit_card" do
        let(:order) { orders(:metova) }
        before do
          order.payment_method = payment_methods(:credit)
          expect(order.total_with_credits).to be >= 900.to_money
        end

        subject { PaymentService.authorize(order.payment_method, amount: order.total_with_credits, capture: true) }
        it { is_expected.not_to be_success }
      end
      context "with ACH" do
        let(:order) { orders(:metova) }
        before do
          order.payment_method = payment_methods(:ach)
          expect(order.total_with_credits).to be >= 900.to_money
        end

        subject { PaymentService.authorize(order.payment_method, amount: order.total_with_credits, capture: true) }
        it { is_expected.not_to be_success }
      end
    end
  end
end
