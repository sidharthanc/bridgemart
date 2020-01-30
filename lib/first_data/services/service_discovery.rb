module FirstData
  module Services
    # This Service provides discovery for the active service url to use for FD requests
    class ServiceDiscovery
      # The static service discovery urls that come from the registration process (SRS)
      def self.service_discovery_url
        all_service_discovery_urls.sample
      end

      def self.all_service_discovery_urls
        FirstData::Client.credentials.fetch(:service_discovery_urls)
      end

      def initialize
        @unresponsive_service_discovery_urls = []
      end

      def next_discovery_url
        (self.class.all_service_discovery_urls - @unresponsive_service_discovery_urls).sample
      end

      # Run discovery across potentially multiple hosts, returning an array of service hosts
      def perform
        if next_discovery_url.present?
          url = next_discovery_url
          service_host_urls = discover(url: url)
          return service_host_urls if service_host_urls.present?
        else
          raise "No reachable service discovery hosts available"
        end
      rescue Errno::EHOSTDOWN, Faraday::TimeoutError
        @unresponsive_service_discovery_urls << url
        retry
      end

      # Run discovery against a single host
      def discover(url:)
        response = FirstData::Request.new(url: url, method: :get)&.perform
        response.dig('ServiceDiscoveryResponse', 'ServiceProvider').pluck("URL") if response.success?
      end
    end
  end
end
