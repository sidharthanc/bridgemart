# Automatically set the Accept header to JSON if you're
# describing a controller in the Api or API namespace

RSpec.configure do |config|
  config.before do
    @request.env['HTTP_ACCEPT'] = 'application/json' if described_class&.name =~ /Api|API/ && @request.present?
  end
end
