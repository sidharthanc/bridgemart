module Enrollment
  class BaseController < ::ApplicationController
    layout 'enrollment'
    helper_method :navigation
  end
end
