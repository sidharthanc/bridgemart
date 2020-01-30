RSpec.describe CodeMailer, type: :mailer do
  describe 'registered_email' do
    let!(:member) { create(:member) }
    let(:mail) { described_class.registered_email(member).deliver_now }

    it 'creates a notification record with the notice_type set to the right class name' do
      expect { mail }.to change(Notification, :count).by(1)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([member.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['NoReply@BridgeMart.com'])
    end

    it 'has a template-id' do
      expect(mail["template-id"].value).to be_present
    end
  end
end
