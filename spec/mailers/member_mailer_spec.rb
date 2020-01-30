RSpec.describe MemberMailer, type: :mailer do
  describe 'deactivate_mail' do
    let!(:member) { create(:member) }
    let(:mail) { described_class.deactivate_member(member).deliver_now }

    it 'creates a notification record' do
      expect { mail }.to change(Notification, :count).by(1)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([member.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['NoReply@BridgeMart.com'])
    end
  end

  describe 'deactivate_code' do
    let!(:code) { build(:activated_code) }
    let(:mail) { described_class.deactivate_code(code).deliver_now }

    it 'creates a notification record with the notice_type set to the right class name' do
      expect { mail }.to change(Notification, :count).by(1)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([code.member.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['NoReply@BridgeMart.com'])
    end
  end
end
