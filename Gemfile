source 'https://rubygems.org'
gem 'rails', '5.2.0'

gem 'pg'

gem 'aasm'
gem 'active_record_query_trace'
gem 'activeadmin'
gem 'activeadmin_addons'
gem 'active_storage_base64'
gem 'attr_encrypted'
gem 'audited', '~> 4.7'
gem 'azure-storage', require: false
gem 'barby'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.3.1'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap4-kaminari-views'
gem 'cardconnect'
gem 'chronic'
gem 'chunky_png'
gem 'city-state'
gem 'coffee-rails', git: 'https://github.com/rails/coffee-rails.git'
gem 'combine_pdf'
gem 'counter_culture', '~> 2.0'
gem 'creek'
gem 'devise'
gem 'dotenv-rails'
gem 'factory_bot_rails'
gem 'faraday'
gem 'faraday_middleware'
gem 'font-awesome-sass'
gem 'foreman'
gem 'jbuilder'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'kaminari'
gem 'memoizer', '~> 1.0', '>= 1.0.3'
gem 'mjml-rails'
gem 'momentjs-rails'
gem 'money-rails'
gem 'multi_xml'
gem 'oj'
gem 'pagy'
gem "paranoia", "~> 2.2"
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'Rdmtx' # brew install dmtx-utils ; PKG_CONFIG_PATH="/usr/local/opt/imagemagick@6/lib/pkgconfig" gem install rmagick -v '2.16.0'
gem 'responders'
gem 'sass-rails'
gem 'scenic'
gem 'seedbank'
gem 'sendgrid-actionmailer'
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'simple_form'
gem 'skylight'
gem 'smtpapi'
gem 'turbolinks'
gem 'uglifier'
gem 'webpacker', '~> 3.4'
gem 'wisper'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'zero_downtime_migrations'

group :staging, :release, :production do
  gem 'lograge'
  gem 'newrelic_rpm'
  gem 'rack-heartbeat'
  gem 'rack-timeout'
  gem 'rollbar'
end

group :development, :staging, :release do
  gem 'query_diet'
end

group :development, :test do
  gem 'bullet'
  gem 'byebug'
  gem 'faker'
  gem 'listen'
  gem 'rspec-rails'

  gem 'watir'
  gem 'webdrivers'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'guard-rake', require: false
  gem 'guard-rspec', require: false
  gem 'rack-livereload'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'rubocop-performance'

  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit', '~> 1.15.1'
  gem 'climate_control'
  gem 'fakeredis'
  gem 'launchy'
  gem 'pdf-reader'
  gem 'rspec-junit'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
  gem 'timecop' # TODO: We should be able to remove this for AS::TimeHelpers
  gem 'vcr'
  gem 'webmock'
  gem 'webmock-rspec-helper'
  gem 'wisper-rspec', require: false
end
