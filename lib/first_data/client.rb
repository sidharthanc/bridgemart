module FirstData
  class Client
    def self.credentials
      Rails.application.credentials.dig(credential_environment.to_sym, :first_data)
    end

    def self.credential_environment
      FirstData.credential_environment || Rails.env
    end

    def self.service_url
      FirstData.service_url || Rails.cache.fetch('first-data/active_service_url', expires_in: 24.hours) do
        ranked_hosts.first
      end
    end

    # Returns an ordered array of active service urls
    def self.ranked_hosts
      Rails.cache.fetch('first-data/active_service_hosts', expires_in: 12.hours) do
        threads = []
        Array.wrap(service_hosts).each do |url|
          threads << Thread.new do
            Thread.current[:response] = [url, FirstData::Services::Ping.new(url).perform || Float::INFINITY] # Ping returns nil for unreachable / timedout hosts
          end
        end
        responses = threads.collect { |t| t.join; t[:response] }
        responses.reject! { |ping| ping.last == Float::INFINITY } # Do not include unreachable hosts in ranked hosts
        responses.sort_by(&:last).map(&:first)
      end
    end

    # Return an array of hosts to include in service discovery
    def self.service_hosts
      Rails.cache.fetch('first-data/service_hosts', expires_in: 24.hours) do
        FirstData::Services::ServiceDiscovery.new.perform
      end
    end

    # Resets the service url currently in use
    def self.reset_service_url!
      current_host = Rails.cache.fetch('first-data/active_service_url')
      Rails.cache.delete('first-data/active_service_url')
      current_hosts = Rails.cache.fetch('first-data/active_service_hosts')
      current_hosts.try(:delete, current_host)
      if current_hosts.present?
        Rails.cache.write('first-data/active_service_hosts', current_hosts)
      else # We have run out of urls
        Rails.cache.delete('first-data/active_service_hosts')
      end
    end

    def self.reset_service_discovery!
      Rails.cache.delete('first-data/active_service_url')
      Rails.cache.delete('first-data/service_hosts')
    end

    def self.connection(url = FirstData::Client.service_url)
      Faraday.new(url: url) do |faraday|
        faraday.response :logger, ::Logger.new(STDOUT), bodies: true unless Rails.env.test?
        faraday.adapter Faraday.default_adapter
        faraday.options[:open_timeout] = 10 # How long to wait in case a host is down
        faraday.options[:timeout] = 20 # How long to wait for a reply
        faraday.headers['User-Agent'] = credentials[:user_agent]
        faraday.headers['Connection'] = 'Keep-Alive'
        faraday.headers['Cache-Control'] = 'no-cache'
        faraday.headers['Content-Type'] = 'text/xml'
      end
    end

    # This operation *will* establish a new DID for use with the FirstData system and
    # as such will also _invalidate_ any previous DID you may have had.
    # The DID given back becomes your new DID and the credentials file must be updated
    # and promoted to all affected environments.
    # It should be run manually (in a console), not automatically run under any circumstance.
    def self.register!
      puts FirstData::Services::Registration.new.perform
    end
  end
end
