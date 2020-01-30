require Rails.root.join('config', 'environments', 'production')
Rails.application.configure do
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

  config.active_support.deprecation = :log
  config.log_level = :info
  config.active_storage.service = :staging
  config.action_mailer.default_url_options = Rails.application.routes.default_url_options
end
