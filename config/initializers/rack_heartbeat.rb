if defined? Rack::Heartbeat
  Rack::Heartbeat.setup do |config|
    config.heartbeat_path = 'healthz' # default used in kubernettes
  end
end
