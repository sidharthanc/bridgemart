require_relative 'boot'

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.require_master_key = true

    config.middleware.use Rack::Attack unless Rails.env.test?

    config.autoload_paths += %W[#{config.root}/lib]
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.test_framework :rspec, fixture: false, routing_specs: false, helper_specs: false
      g.fixture_replacement :factory_bot
    end

    # Skylight envs
    config.skylight.environments += %w[staging release] if defined?(Skylight)
  end
end
