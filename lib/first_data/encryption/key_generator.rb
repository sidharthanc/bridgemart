require 'openssl'

module FirstData
  module Encryption
    # Utility class for generating a new key pair (and shared secret) for use in
    # the DH key exchange with First Data
    class KeyGenerator
      include Helpers
      FD_DH_PARAMS = File.read(File.expand_path('first_data_dh_params.pem', __dir__)).freeze
      FD_PUBLIC_KEY = OpenSSL::BN.new('6B0276780D3E07911D744F545833005E8C2F755E0FE59A8660527F7B7E070A45EEB853DA70C6EFE2B8BF278F0B4A334A49DF0985635745A3DAD2E85A9C0EEFAE657CC382A0B3EAE9C3F85B0A2305282612CFD2857801131EC9FE313DB9DADFB914A30EE077E8A97E5574CE5BD56661B021C39116913710947FAA38FFCB4FC045', 16).freeze

      def initialize
        @dh = OpenSSL::PKey::DH.new FD_DH_PARAMS # 1.5.1
        dh.generate_key!
      end

      def private_key # A. 1
        dh.priv_key.to_s(16) # BN to hex
      end

      def public_key # A. 1
        dh.pub_key.to_s(16) # BN to hex
      end

      def shared_secret
        bin_to_hex(@dh.compute_key(FD_PUBLIC_KEY))
      end

      private
        attr_reader :dh
    end
  end
end
