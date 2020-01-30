module TokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_authentication_token, on: :create
    validates :authentication_token, presence: true, on: :create
  end

  def generate_authentication_token
    self.authentication_token = SecureRandom.hex
  end
end
