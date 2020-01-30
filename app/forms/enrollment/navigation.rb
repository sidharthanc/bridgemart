module Enrollment
  class Navigation
    attr_accessor :back_path, :next_path

    def initialize(back_path, next_path)
      @back_path = back_path
      @next_path = next_path
    end
  end
end
