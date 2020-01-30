module Support
  DEFAULT_SCALE = 1

  def scale(value)
    value**scale_value
  end

  def scale_value
    ENV.fetch('SCALE', DEFAULT_SCALE)
  end
end
