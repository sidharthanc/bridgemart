class ApplicationMailer < ActionMailer::Base
  default from: 'NoReply@BridgeMart.com'
  layout 'mailer'

  after_action :record_email

  protected
    def record_email
      Notification.create(sent_to: @_message.to, notice_type: self.class.name)
    end
end
