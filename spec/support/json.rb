module JSONHelper
  def json
    case j = JSON[response.body]
    when Array
      j.map(&:with_indifferent_access)
    when Hash
      j.with_indifferent_access
    else
      j
    end
  end
end

RSpec.configure do |config|
  config.include JSONHelper
end
