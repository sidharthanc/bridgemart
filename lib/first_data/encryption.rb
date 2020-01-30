require 'pp'

module FirstData
  module Encryption
    ENCRYPTION_ALGORITHM = "des-ede3-cbc".freeze
    # Generate a new key pair (and shared secret) for use in the DH key exchange
    # with First Data
    def self.generate_key_pair
      key_gen = KeyGenerator.new
      keys = {
        private: key_gen.private_key,
        public: key_gen.public_key,
        shared: key_gen.shared_secret
      }
      pp keys if defined?(Rails::Console)
      keys
    end

    # Generate a new Merchant Working Key
    # @args Shared Secret [String] The Shared Secret from the DH key exchange, as a hex string.
    def self.generate_merchant_working_key(shared_secret)
      key_gen = MerchantKeyGenerator.new(shared_secret)
      keys = {
        merchant_key: bin_to_hex(key_gen.merchant_working_key),
        merchant_key_encrypted: key_gen.merchant_working_key_encrypted
      }
      pp keys if defined?(Rails::Console)
      keys
    end

    def self.encrypt_ean(value, working_key = FirstData::Encryption.working_key)
      cipher = OpenSSL::Cipher.new(ENCRYPTION_ALGORITHM)
      cipher.encrypt
      cipher.padding = 0
      cipher.key = working_key
      cipher.iv = zeros
      encrypted = cipher.update(ean_block(value))
      bin_to_hex(encrypted)
    end

    def self.decrypt_ean(value)
      decipher = OpenSSL::Cipher.new(ENCRYPTION_ALGORITHM)
      decipher.decrypt
      decipher.padding = 0
      decipher.key = working_key
      decipher.iv = zeros
      decrypted_block = decipher.update([value].pack('H*'))
      # TODO: Check the checkvalue maybe?
      decrypted_block.bytes[-8..-1].map(&:chr).join
    end

    def self.working_key
      [FirstData::Client.credentials[:merchant_working_key]].pack('H*')
    end

    def self.ean_block(value)
      ean = value.ljust(8)
      random_bytes(7).tap do |data|
        data << checksum(ean)
        data << ean
      end
    end

    module Helpers
      # Generates random binary data
      # @arg [Integer] number_of_bytes: Number of bytes of binary data to generate, defaults 8
      def random_bytes(number_of_bytes = 8)
        SecureRandom.random_bytes(number_of_bytes)
      end

      # 8-byte block of _hex_ zeros
      def zeros
        "\x00" * 8
      end

      # Coverts a Binary value to ASCII HEX
      def bin_to_hex(s)
        s&.unpack('H*')&.first
      end

      # Converts an ASCII HEX value to Binary
      def hex_to_bin(s)
        [s].pack('H*')
      end

      def checksum(v)
        sum = v.bytes.reduce(:+)
        [sum].pack('c*')
      end

      # :nocov
      def output_value_with_size(v, name = "Value")
        value = v.dup
        value = bin_to_hex(value) unless value.is_a? String
        puts "#{name}: " + value + " (#{value.bytes.size} bytes)"
      end
      # :nocov
    end
    extend Helpers
  end
end
