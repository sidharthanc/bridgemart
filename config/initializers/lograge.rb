Rails.application.configure do
  if defined?(Lograge)
    config.lograge.enabled = true

    config.lograge.custom_options = lambda do |event|
      exceptions = %w[controller action format id]
      {
        params: event.payload[:params].except(*exceptions),
        exception: event.payload[:exception], # ["ExceptionClass", "the message"]
        exception_object: event.payload[:exception_object] # the exception instance
      }
    end
  end
end
