module ClosedLoop
  class Request < Payload
    class MissingRequiredField < ArgumentError; end
    MAX_RETRIES = 3
    attr_reader :transaction, :fields

    def initialize(transaction: nil)
      @transaction = transaction
      @fields = []
      super()
      @inside_timeout = false
    end

    def perform(validate: true)
      validate_required_fields! if validate
      request = FirstData::Request.new(service: 'Transaction', service_id: '104', payload: to_payload)
      ServiceActivity.record(self.class, @transaction) do |_activity|
        ClosedLoop::Response.new(request.perform)
      end
    rescue Errno::EHOSTDOWN, Faraday::ConnectionFailed
      FirstData::Client.reset_service_url! # Is this too heavy handed?
      retry
    rescue Faraday::TimeoutError
      raise if @inside_timeout

      @inside_timeout = true
      unless FirstData.test_environment?
        sleep rand(3..5)
        warn 'Sleeping ClosedLoop::Request'
      end
      transmit_timeout_reversal
      raise
    end

    def transmit_timeout_reversal
      timeout_reversal_request = build_reversal_payload
      timeout_reversal_request.perform(validate: false)
    end

    def build_reversal_payload
      timeout_reversal_request = self.class.new(transaction: :timeout_reversal)
      timeout_reversal_request.instance_variable_set '@fields', fields
      old_code = transaction_type.fetch :code
      timeout_reversal_request.add_field(:original_transaction_request_code, old_code)
      timeout_reversal_request.transaction_type[:code] = TRANSACTION_TYPES.dig :timeout_reversal, :code
      timeout_reversal_request
    end

    def header
      @header ||= [].tap do |header|
        header << ['SV.', credentials[:mid]].join
        header << [VERSION_NUMBER, FORMAT_NUMBER, transaction_type.fetch(:code, nil)].join
      end
      @header.join(FS)
    end

    def transaction_type
      TRANSACTION_TYPES[transaction] || {}
    end

    # Adds a field to the request
    def add_field(identifier, value = nil)
      @fields << build_field(identifier, value)
    end

    def build_field(identifier, value = nil)
      field_element = FIELDS.fetch(identifier, nil)
      raise UnknownField unless field_element.present?

      code = field_element.fetch(:code)
      processed_value = if field_element[:lambda]
                          if value
                            field_element[:lambda].call(*value)
                          else
                            field_element[:lambda].call
                          end
                        else
                          value
                        end
      # TODO: need to verify no duplicates?
      [code, processed_value]
    end

    def to_payload
      o = header
      o << FS
      o << fields.collect(&:join).join(FS)
      o
    end

    def included_codes
      fields.collect(&:first)
    end

    def validate_required_fields!
      raise MissingRequiredField, "Missing Fields #{(transaction_type.fetch(:fields) - included_codes).join(',')}; Included Fields #{included_codes}" if (transaction_type.fetch(:fields) - included_codes).present?
    end
  end
end
