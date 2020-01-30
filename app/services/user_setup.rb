class UserSetup
  def initialize(user)
    @user = user
    @user.password = generate_password
    @user.save
  end

  def send_invitation_email
    UserMailer.credentials_email(@user, @user.password).deliver_later if @user.persisted?
  end

  def generate_password
    Devise.friendly_token.first(8)
  end
end
