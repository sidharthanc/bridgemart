describe PaymentJob do
  describe 'perform' do
    let(:order) { orders(:metova_unpaid) }
    let(:paid_order) { orders(:metova) }

    before do
      order.members.push members(:kaleb)
      order.payment_method = payment_methods(:credit)
      order.save
    end

    context 'PaymentService accepts the new customer and payment request' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))
      end

      it 'will not process an order when the order is already processed' do
        order.update(processed_at: DateTime.current)
        expect(PaymentJob).not_to receive(:perform_later)
        subject.perform order
      end

      it 'will not process already paid orders' do
        order.update(paid_at: DateTime.current)
        expect(PaymentJob).not_to receive(:perform_later)
        subject.perform paid_order
      end

      it 'fires off the InvoiceMailer on a success' do
        expect { subject.perform order }.to enqueue_job(ActionMailer::DeliveryJob).with('InvoiceMailer', 'enrollment_invoice_email', 'deliver_now', order)
      end

      context 'Generate Codes' do
        it 'generates codes on success and order starts today' do
          expect { subject.perform order }.to enqueue_job(Orders::GenerateCodesJob)
        end

        it 'does not generate codes on success if order starts after today' do
          order.update starts_on: 1.day.from_now
          expect { subject.perform order }.to_not enqueue_job(Orders::GenerateCodesJob)
          subject.perform order
        end
      end

      it 'does not apply an error message to the order' do
        subject.perform order
        expect(order.error_message).to eq(nil)
      end
    end

    context 'There is an error from PaymentService' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :failure))
      end

      it "sets an error on the order" do
        subject.perform order
        expect(order.error_message).to eq('Invalid Card')
      end

      it 'does not send an invoice email' do
        expect { subject.perform order }.not_to enqueue_job(ActionMailer::DeliveryJob).with('InvoiceMailer', 'enrollment_invoice_email', 'deliver_now', order)
      end

      it 'does not create a payment method' do
        expect { subject.perform order }.not_to change(PaymentMethod, :count)
      end

      it 'does not create a signature' do
        expect { subject.perform order }.not_to change(Signature, :count)
      end

      it 'saves error in credit purchase' do
        subject.perform order
        expect(subject.credit_purchase.error_message).to be_present
      end
    end

    context 'the total cost of the order is covered by credits' do
      before do
        order.organization.credits.create!(source: order, amount: order.total.dollars)
        order.line_items.create(source: order, charge_type: :credit, amount: order.total.dollars, description: "Applied Credit from #{order.organization.name}")
      end

      it 'does not make a call to PaymentService' do
        expect(PaymentJob).not_to receive(:process)
        subject.perform order
      end

      it 'payment is processed successfully' do
        expect_any_instance_of(Order).to receive(:total_with_credits).once.and_return(0.to_money)
        expect(order.paid_at).to be_nil
        subject.perform order
        expect(order.paid_at).to be_truthy
      end

      it 'sends an invoice email' do
        expect { subject.perform order }.to enqueue_job(ActionMailer::DeliveryJob).with('InvoiceMailer', 'enrollment_invoice_email', 'deliver_now', order)
      end

      it 'does not set a payment method of the order' do
        expect { subject.perform order }.not_to change(PaymentMethod, :count)
      end
    end

    context 'partial cost of the order is covered by credits' do
      before do
        order.organization.credits.create!(source: order, amount: order.total.dollars - 1)
        order.line_items.create(source: order, charge_type: :credit, amount: order.total.dollars - 1, description: "Applied Credit from #{order.organization.name}")
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :success))
      end

      it 'still makes a call to PaymentService' do
        expect(PaymentJob).not_to receive(:process)
        subject.perform order
      end

      it 'payment is processed successfully' do
        expect(order.paid_at).to be_nil
        subject.perform order
        expect(order.paid_at).to be_truthy
        expect(order.processed_at).to be_present
      end

      it 'will not an order when the order is already processed' do
        order.touch(:processed_at)
        expect(PaymentJob).not_to receive(:perform_later)
        subject.perform order
      end

      it 'will not process already paid orders' do
        order.touch(:paid_at)
        expect(PaymentJob).not_to receive(:perform_later)
        subject.perform paid_order
      end

      it 'fires off the InvoiceMailer on a success' do
        expect { subject.perform order }.to enqueue_job(ActionMailer::DeliveryJob).with('InvoiceMailer', 'enrollment_invoice_email', 'deliver_now', order)
      end

      it 'creates a CreditPurchase' do
        expect { subject.perform order }.to change(CreditPurchase, :count).by(1)
        expect(subject.credit_purchase.amount).to eq 1.to_money
      end

      context 'Generate Codes' do
        it 'generates codes on success and order starts today' do
          expect { subject.perform order }.to enqueue_job(Orders::GenerateCodesJob)
        end

        it 'does not generate codes on success if order starts after today' do
          order.update starts_on: 1.day.from_now
          expect(Orders::GenerateCodesJob).not_to receive(:execute)
          subject.perform order
        end
      end

      it 'does not apply an error message to the order' do
        subject.perform order
        expect(order.error_message).to eq(nil)
      end
    end

    context 'There is an error from PaymentService' do
      before do
        allow(CardConnect::Service::Authorization).to receive(:new)
          .and_return(PaymentServiceTestHelpers.stub_payment_service(endpoint: :authorize, response: :failure))
      end

      it "sets an error on the order" do
        expect { subject.perform order }.to change(order, :error_message).to('Invalid Card')
      end

      it 'does not send an invoice email' do
        expect { subject.perform order }.not_to enqueue_job(ActionMailer::DeliveryJob).with('InvoiceMailer', 'enrollment_invoice_email', 'deliver_now', order)
      end

      it 'does not create a payment method' do
        expect { subject.perform order }.not_to change(PaymentMethod, :count)
      end

      it 'does not create a signature' do
        expect { subject.perform order }.not_to change(Signature, :count)
      end

      it 'creates a Service Activity Record' do
        expect { subject.perform(order) }.to change(ServiceActivity, :count)
      end
    end
    context 'There is an unknown exception thrown during processing' do
      it "sets an error on the order and resets processing" do
        allow(PaymentService).to receive(:authorize).and_raise(RuntimeError.new("Something Happened Dave"))
        subject.perform order

        expect(order.error_message).to include('Something Happened Dave')
        expect(order.processed_at).to be_present
        expect(subject.credit_purchase.error_message).to include('Something Happened Dave')
      end
    end
  end
end
