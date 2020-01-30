require File.expand_path('../../app/services/payment_service', __dir__)
require 'faraday/adapter/test'

# Stub out the Faraday connection for testing.
module CardConnect
  class Connection
    undef :connection if method_defined? :connection

    def connection
      @connection = Faraday.new(faraday_options) do |faraday|
        faraday.request :basic_auth, @config.api_username, @config.api_password
        faraday.request :json

        faraday.response :json, content_type: /\bjson$/
        faraday.response :raise_error

        faraday.adapter :test do |stubs|
          yield(stubs)
        end
      end
    end
  end
end

module PaymentServiceTestHelpers
  def self.stub_payment_service(endpoint: :authorize, response: :success)
    klass = case endpoint
            when :authorize
              CardConnect::Service::Authorization
            when :capture
              CardConnect::Service::Capture
      end

    resp = case response
           when :success
             valid_auth_response
           when :failure
             invalid_auth_response
      end

    @card_connect_connection = CardConnect::Connection.new.connection do |stubs|
      stubs.put(@card_connect_service.path) { [200, {}, resp] }
    end
    @card_connect_service = klass.new(@card_connect_connection)
  end

  def self.valid_auth_response
    {
      'respstat' => 'A',
      'account' => '41XXXXXXXXXX1111',
      'token' => '9419786452781111',
      'retref' => '343005123105',
      'amount' => '111',
      'merchid' => '020594000000',
      'respcode' => '00',
      'resptext' => 'Approved',
      'avsresp' => '9',
      'cvvresp' => 'M',
      'authcode' => '046221',
      'respproc' => 'FNOR',
      'commcard' => 'N',
      'profileid' => '12345678',
      'acctid' => nil
    }
  end

  def self.invalid_auth_response
    {
      'respstat' => 'C',
      'account' => '41XXXXXXXXXX1111',
      'token' => '9419786452781111',
      'retref' => '343005123105',
      'amount' => '111',
      'merchid' => '020594000000',
      'respcode' => '11',
      'resptext' => 'Invalid Card',
      'avsresp' => '9',
      'cvvresp' => 'M',
      'authcode' => '046221',
      'respproc' => 'FNOR',
      'commcard' => 'N',
      'profileid' => '12345678',
      'acctid' => nil
    }
  end
end
