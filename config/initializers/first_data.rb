FirstData.setup do |config|
  # This is a bit out of date and needs updating
  config.credential_environment = :staging if Rails.env.production? && ENV['APP_NAME'] == 'bridge-k8s-pre-prod'
  config.service_url = ["https://staging2.datawire.net/sd", "https://staging1.datawire.net/sd"].sample unless (Rails.env.production? || Rails.env.release?) || Rails.env.test?
end
