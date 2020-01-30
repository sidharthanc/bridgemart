ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require File.expand_path('support/simplecov', __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'fakeredis'
require 'sidekiq'
require 'rake'
require 'wisper/rspec/matchers'
RailsApp::Application.load_tasks

require 'webmock/rspec'
WebMock.disable_net_connect! allow_localhost: true

ActiveRecord::Migration.maintain_test_schema!

# FIXME: I should not need these as they live in lib
require 'closed_loop'
require 'first_data'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
  config.use_transactional_fixtures = true
  config.global_fixtures = :all
  config.fixture_path = Rails.root.join('spec', 'fixtures')
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.filter_run_excluding broken: true

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Wisper::RSpec::BroadcastMatcher
  config.include ActionView::Helpers::TranslationHelper
  config.include MoneyRails::ActionViewExtension
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FirstDataTestHelper
  config.include BinaryHelpers

  config.after(:suite) do
    ProductCategory.find_each do |product_category|
      product_category.icon.purge
    end

    examples = RSpec.world.filtered_examples.values.flatten
    if examples.none?(&:exception)
      # No failures
      Rake::Task['test_cleanup:clean'].invoke
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def attach_test_image(product_category)
  product_category.tap { |obj| obj.icon.attach io: File.open(Rails.root.join('app', 'assets', 'images', 'missing-image.png')), filename: 'missing-image.png' }
end

def attach_images_to_product_categories
  ProductCategory.find_each { |product_category| attach_test_image(product_category) }
end

redis_opts = { url: 'redis://127.0.0.1:6379/1' }
# If fakeredis is loaded, use it explicitly
redis_opts[:driver] = Redis::Connection::Memory if defined?(Redis::Connection::Memory)

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end
