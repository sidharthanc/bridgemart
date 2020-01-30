RSpec.describe UserMailer, type: :mailer do
  describe 'credentials_email' do
    let!(:user) { create(:user) }
    let(:mail) { described_class.credentials_email(user, 'password').deliver_now }

    it 'creates a notification record with the notice_type set to the right class name' do
      expect { mail }.to change(Notification, :count).by(1)
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
