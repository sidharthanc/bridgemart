require Rails.root.join('config', 'environments', 'staging')
Rails.application.configure do
  config.active_support.deprecation = :log
  config.log_level = :info
  config.active_storage.service = :release
  config.action_mailer.default_url_options = Rails.application.routes.default_url_options
end
