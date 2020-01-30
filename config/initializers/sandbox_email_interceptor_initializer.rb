ActionMailer::Base.register_interceptor(SandboxEmailInterceptor) unless Rails.env.production?
