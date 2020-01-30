module ClosedLoop
  class Payload
    def self.credentials
      FirstData::Client.credentials
    end
    delegate :credentials, to: FirstData::Client

    def initialize
      yield(self) if block_given?
    end
  end
end
