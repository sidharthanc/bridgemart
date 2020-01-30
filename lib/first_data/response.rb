module FirstData
  # Takes the response XML and converts it into a useable value object accessed
  # akin to a hash
  class Response
    SUCCESS_STATUS_CODE = 'OK'.freeze
    RETRY_STATUS_CODE = 'Retry'.freeze

    attr_reader :body, :status, :fields
    delegate :[], :fetch, :dig, to: :fields

    def initialize(fd_response)
      raise "Empty Body response!" unless fd_response&.body.present?

      @body = Hash.from_xml(fd_response.body)
      @fields = @body.fetch('Response', {})
      @status = @fields.dig('Status', 'StatusCode')
    end

    def success?
      @status == SUCCESS_STATUS_CODE
    end

    def retry?
      @status == RETRY_STATUS_CODE
    end
  end
end
