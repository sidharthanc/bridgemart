module SignUpable
  extend ActiveSupport::Concern

  def sign_in_and_invite_user(sign_up)
    sign_in :user, sign_up.user unless signed_in?
    mail_password_to sign_up
  end

  def mail_password_to(sign_up)
    # Security Issue; Password stored in cleartext in redis?
    UserMailer.credentials_email(sign_up.user, sign_up.generated_password).deliver_later
  end
end
