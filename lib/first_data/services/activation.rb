module FirstData
  module Services
    #:nocov:
    class Activation < FirstData::Request
      def initialize
        super(url: FirstData::Client.credentials[:registration_url], service: 'Activation', service_id: '104')
      end

      def perform
        loop do
          response = super()

          if response.retry?
            warn 'Sleeping  FirstData::Services::Activation'
            sleep(30)
            redo
          elsif response.success?
            response
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
