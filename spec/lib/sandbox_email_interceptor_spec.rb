describe SandboxEmailInterceptor do
  describe 'interceptor' do
    let!(:member) { create(:member) }
    let(:mail) { CodeMailer.registered_email(member).deliver_now }

    it 'sets perform_deliveries as false' do
      expect(mail.perform_deliveries).to eq false
    end

    it 'records the intercepted email' do
      mail
      expect(Notification.last.sent_to).to eq [member.email].to_s
      expect(Notification.last.template_id).to eq mail["template_id"].value
    end
  end
end
