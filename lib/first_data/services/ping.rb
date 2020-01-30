require 'benchmark'

module FirstData
  module Services
    class Ping < FirstData::Request
      def initialize(url)
        super(service: 'Ping', url: url, service_id: '104')
      end

      def perform
        api_response_time = nil
        http_response_time = Benchmark.measure do
          api_response_time = begin
            response = super()
                              rescue Errno::EHOSTDOWN, Faraday::ConnectionFailed, Faraday::TimeoutError
                                nil # Hacky, but does what we want
                              rescue RuntimeError
                                nil # log this?
                              else
                                response.dig('PingResponse', 'ServiceCost', 'TransactionTimeMs') if response.success?
          end
        end.real
        http_response_time + (api_response_time.to_f * 0.001) if api_response_time.present?
      end
    end
  end
end
