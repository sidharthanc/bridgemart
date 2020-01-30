require 'builder/xmlmarkup'

module FirstData
  class Request
    class InvalidCredentials < StandardError; end
    class InvalidRequest < StandardError; end
    class PayloadNotGiven < StandardError; end

    PIPE = '|'.freeze
    delegate :credentials, to: FirstData::Client

    attr_reader :service, :method, :connection, :body

    def initialize(**args)
      @service = args.delete(:service)
      payload = args.delete(:payload)
      @skip_did = args.delete(:skip_did) || false
      @method = args[:method] ||= :post
      raise InvalidRequest, 'Invalid Request Method' unless Faraday::Connection::METHODS.include?(method)

      @connection = FirstData::Client.connection(args[:url] || FirstData::Client.service_url)
      @body = xml_builder(service_id: args[:service_id], payload: payload).target!
    end

    def perform
      response = connection.send(method) do |request|
        request.body = body
      end
      if response
        FirstData::Response.new(response)
      else
        raise
      end
    end

    private
      def client_reference
        @client_reference ||= build_client_reference
      end

      # Client Ref should be 14 digits set up as follows "tttttttVnnnrrr":
      # "ttttttt" = 7 digit transaction ID that is unique to each transaction. Pad with trailing zeros or truncate as required.
      # "V" = the letter "V" for Version.  The version should be updated as the version of the application changes.
      # "nnn" = the version number, 3 characters long, no periods or spaces
      # "rrr" = the revision number, 3 characters long, no periods or spaces
      # Example: Version 2.5 = tttttttV002500
      def build_client_reference
        transaction_id = Time.current.strftime('%02M%02S%03L')
        version_number = 1
        revision_number = 0
        format("%.7sV%.03d%.03d", transaction_id, version_number, revision_number)
      end

      # Build the XML request payload
      def xml_builder(service_id: nil, payload: nil)
        builder = Builder::XmlMarkup.new
        builder.instruct!
        builder.Request('Version' => '3') do |request|
          request.ReqClientID do |auth|
            auth.DID(credentials[:did]) unless @skip_did
            auth.App(credentials[:app])
            auth.Auth([credentials[:mid], credentials[:tid]].join(PIPE))
            auth.ClientRef(client_reference)
          end
          if service
            request.tag!(service) do |srv|
              srv.ServiceID(service_id) if service_id
              srv.Payload(payload) if payload.present?
            end
          end
        end
        builder
      end
  end
end
