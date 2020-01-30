RSpec.describe InvoiceMailer, type: :mailer do
  describe 'enrollment_invoice_email' do
    let!(:order) { create(:order) }
    let(:user) { order.primary_user }
    let(:mail) { described_class.enrollment_invoice_email(order).deliver_now }

    it 'creates a notification record with the notice_type set to the right class name' do
      expect { mail }.to change(Notification, :count).by(1)
    end

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('mailers.invoice_mailer.pre_plan_invoice.subject'))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['NoReply@BridgeMart.com'])
    end

    it 'has a template-id' do
      expect(mail["template-id"].value).to be_present
    end
  end
end
