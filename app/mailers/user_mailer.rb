class UserMailer < ApplicationMailer
  CREDENTIALS_EMAIL_TEMPLATE_ID = 'd-05439ac29bde45a0b329503e261b9719'.freeze

  def credentials_email(user, password)
    dynamic_template_data = {
      firstname: [user.first_name],
      emailaddress: [user.email],
      password: [password],
      link: [new_user_password_url]
    }
    mail to: user.email, body: 'email body', template_id: CREDENTIALS_EMAIL_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html'
  end
end
