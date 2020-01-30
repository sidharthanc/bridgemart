RSpec.describe CustomMailer, type: :mailer do
  describe 'registered_email' do
    let!(:user) { create(:user) }
    let(:mail) { described_class.reset_password_instructions(user, user.authentication_token).deliver_now }

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
