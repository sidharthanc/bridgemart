module FirstData
  autoload :Client, 'first_data/client'
  autoload :Encryption, 'first_data/encryption'
  autoload :Request, 'first_data/request'
  autoload :Response, 'first_data/response'
  autoload :Transaction, 'first_data/transaction'

  module Encryption
    autoload :KeyGenerator, 'first_data/encryption/key_generator'
    autoload :MerchantKeyGenerator, 'first_data/encryption/merchant_key_generator'
  end

  module Services
    autoload :Activation, 'first_data/services/activation'
    autoload :Ping, 'first_data/services/ping'
    autoload :Registration, 'first_data/services/registration'
    autoload :ServiceDiscovery, 'first_data/services/service_discovery'
  end

  class Error < ::StandardError
  end

  mattr_accessor :credential_environment
  @@credential_environment = nil

  mattr_accessor :service_url
  @@service_url = nil

  def self.setup
    yield self
  end

  def self.test_environment?
    Rails.env.test?
  end
end
