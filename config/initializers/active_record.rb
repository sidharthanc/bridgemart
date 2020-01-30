class CacheFreeLogger < SimpleDelegator
  def debug(message, *args, &block)
    super unless message.include? 'CACHE'
  end
end

# Overwrite ActiveRecord’s logger
ActiveRecord::Base.logger = CacheFreeLogger.new(ActiveRecord::Base.logger) if Rails.env.development?
