require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true # Needed for legacy testing
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
