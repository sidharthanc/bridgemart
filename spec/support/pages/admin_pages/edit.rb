require_relative 'base'

module AdminPages
  class Edit < Base
    def submit
      click_submit :update
    end
  end
end
