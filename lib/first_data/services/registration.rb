module FirstData
  module Services
    #:nocov:
    class Registration < FirstData::Request
      def initialize
        super(url: FirstData::Client.credentials[:registration_url], service: 'Registration', service_id: '104', skip_did: true)
      end

      def perform
        loop do
          response = super()

          if response.retry?
            warn 'Sleeping  FirstData::Services::Registration'
            sleep(10)
            redo
          elsif response.success?
            response.dig('Response', 'RegistrationResponse')
          else
            warn "Registration Failed: #{response.dig('Response', 'Status')}"
          end
          break
        end
      end
    end
    #:nocov:
  end
end
