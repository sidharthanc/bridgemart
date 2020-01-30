module ClosedLoop
  class Response < Payload
    SUCCESS = 'OK'.freeze
    ERROR_CODES = {}.tap do |error|
      # error['00'] = 'Completed OK'
      error['01'] = 'Insufficient funds.'
      # error['02'] = 'Account closed.'
      error['03'] = 'Unknown account.'
      error['04'] = 'Inactive account.'
      error['05'] = 'Expired card.'
      error['06'] = 'Invalid transaction code.'
      error['09'] = 'System error'
      error['12'] = 'Invalid transaction format.'
      error['27'] = 'Request not permitted by this account'
      error['38'] = 'No transactions available.'
      error['41'] = 'Invalid status change. The status change requested (e.g. lost/stolen, freeze active card) cannot be performed.'
      error['45'] = 'Invalid EAN'
      error['71'] = 'Fraud Count Exceeded'
    end.freeze

    STATUS_CODE_CALLBACKS = {
      'Timeout' => -> { raise Errno::EHOSTDOWN },
      'OtherError' => -> { raise Errno::EHOSTDOWN },
      '008' => -> { raise Errno::EHOSTDOWN },
      'OK' => -> {},
      'AuthenticationError' => -> {},
      'UnknownServiceID' => -> {},
      'WrongSessionContext' => -> {},
      'AccessDenied' => -> {},
      'Failed' => -> {}
    }.freeze
    RETURN_CODE_CALLBACKS = {
      # Add error codes here with appropriate callbacks as needed
      '203' => -> { raise Faraday::TimeoutError },
      '204' => -> { raise Faraday::TimeoutError },
      '205' => -> { raise Faraday::TimeoutError },
      '206' => -> { raise Faraday::TimeoutError },
      '405' => -> { raise Faraday::TimeoutError },
      '505' => -> { raise Faraday::TimeoutError }
    }.freeze

    attr_reader :header, :fields

    def initialize(first_data_response)
      run_return_code_callback_for(first_data_response.dig('TransactionResponse', 'ReturnCode'))
      payload = first_data_response.dig('TransactionResponse', 'Payload')
      if payload.present?
        field_data = payload.split(FS)
        @header = field_data.shift # Remove the header field
        @response_indicator = field_data.shift
        @fields = Hash[field_data.collect { |data| parse_field(data) }]
      end
    end

    def error_message
      return unless failure?

      ERROR_CODES.fetch(fields[:response_code]) do |code|
        raise UnknownErrorCode, code
      end
    end

    def success?
      # this is a bit of a guess from the docs
      fields[:response_code] == '00'
    end

    def failure?
      !success?
    end

    protected
      def parse_field(data)
        [RESPONSE_FIELDS.fetch(data[0..1]) { data[0..1] }, data[2..-1]]
        # raise UnknownField, "UnknownField #{data[0..1]}"
      end

      def run_status_code_callback_for(status_code)
        if STATUS_CODE_CALLBACKS[status_code]
          STATUS_CODE_CALLBACKS[status_code].call
        else
          # un-recognized status codes should trigger url failover
          raise Errno::EHOSTDOWN
        end
      end

      def run_return_code_callback_for(return_code)
        RETURN_CODE_CALLBACKS[return_code]&.call
      end
  end
end
