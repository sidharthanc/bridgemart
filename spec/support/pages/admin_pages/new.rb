require_relative 'base'

module AdminPages
  class New < Base
    def submit
      click_submit :create
    end
  end
end
