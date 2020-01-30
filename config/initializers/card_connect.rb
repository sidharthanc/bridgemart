CardConnect.configure do |config|
  credentials = Rails.application.credentials.dig(Rails.env.to_sym, :cardconnect)
  config.merchant_id = credentials[:merchant_id]
  config.api_username = credentials[:api_username]
  config.api_password = credentials[:api_password]
  config.endpoint = credentials[:endpoint]
end
