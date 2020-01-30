class CustomMailer < Devise::Mailer
  default from: 'NoReply@BridgeMart.com'
  RESET_PASSWORD_TEMPLATE_ID = 'd-d05df5982afd45108b7fe11da994a929'.freeze

  def reset_password_instructions(user, token, _opts = {})
    dynamic_template_data = {
      link: [edit_user_password_url(reset_password_token: token)],
      full_name: [user.full_name]
    }
    mail to: user.email, body: 'email body', template_id: RESET_PASSWORD_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html'
  end
end
