if defined?(Bullet)
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = true
      Bullet.add_footer = true unless Rails.env.test?
      Bullet.raise = true if Rails.env.test? && ENV['BULLET']
    end
  end
end
