module EML
  module Client
    USE_STAGING_SERVICE_IN_PRODUCTION = false
    MAX_ATTEMPTS = 3

    CREDENTIAL_ENV = if Rails.env.production? && USE_STAGING_SERVICE_IN_PRODUCTION
                       :staging
                     else
                       Rails.env.to_sym
    end

    CREDENTIALS = Rails.application.credentials[CREDENTIAL_ENV]

    BASE_URL = CREDENTIALS.dig :eml, :base_url
    USERNAME = CREDENTIALS.dig :eml, :username
    PASSWORD = CREDENTIALS.dig :eml, :password
    MERCHANT_GROUP = CREDENTIALS.dig :eml, :merchant_group
    PROGRAM = CREDENTIALS.dig :eml, :program

    def get(url, params: {}, page: 1, per: 20, &block)
      response = do_request :get, url_paginated(url, page, per), params
      if block_given? && yield(response).any?
        get url, page: page + 1, &block
      else
        response
      end
    end

    def post(url, params: {})
      url += "?fields=all,pan&program=#{PROGRAM}&search_parameter=ExternalId"
      do_request :post, url, params
    end

    def do_request(method, url, params)
      ServiceActivity.record("EML::Client", url) do |_activity|
        attempts = 0
        begin
          response = http.send(method) do |req|
            req.url url
            req.body = params.merge default_params
          end
        rescue Errno::ECONNRESET => e
          attempts += 1
          attempts <= MAX_ATTEMPTS ? retry : raise
        end

        raise EML::Error, response.body.dig('message') unless response.success?

        response.body
      end
    end

    private
      def http
        @http ||= Faraday.new(url: BASE_URL) do |faraday|
          faraday.basic_auth USERNAME, PASSWORD
          faraday.request  :json
          faraday.response :json
          faraday.adapter  :net_http
        end
      end

      def default_params
        {
          merchant_group: MERCHANT_GROUP,
          program: PROGRAM,
          search_parameter: 'ExternalId'
        }
      end

      def url_paginated(url, page, take)
        skip = (page - 1) * take
        "#{url}?skip=#{skip}&take=#{take}"
      end
  end
end
