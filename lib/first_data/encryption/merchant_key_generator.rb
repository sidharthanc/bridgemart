require 'securerandom'
require 'digest'

module FirstData
  module Encryption
    class MerchantKeyGenerator
      include Helpers
      attr_reader :shared_secret

      # Given a shared_secret (from the key generation process), creates merchant
      # working key (binary)
      # Optionally allows for retreiving the encypted form for transfer (#encrypted)
      # See: FirstData::Encryption::KeyGenerator
      def initialize(shared_secret)
        @shared_secret = hex_to_bin(shared_secret)
        @merchant_working_key = detect_and_correct_odd_parity(revise(random_seed))
        @derived_3des_kek = nil
      end

      attr_reader :merchant_working_key

      # Encrypts the merchant working key
      def merchant_working_key_encrypted
        bin_to_hex(encrypted_key_block)
      end

      private

        def kek
          shared_secret_sha = Digest::SHA1.digest(@shared_secret) # B.1
          shared_secret_sha.bytes[0...16].pack('C*') # B.2
        end

        def derived_3des_kek
          detect_and_correct_odd_parity(revise(kek))
        end

        def random_seed
          random_bytes(16)
        end

        # Append the first 8 bytes of the VALUE to VALUE
        def revise(value)
          (value.bytes + value.bytes[0, 8]).pack('c*') # B.3
        end

        # Detect and 'correct' Odd Parity
        def detect_and_correct_odd_parity(value)
          flip_low_order_bit = lambda do |byte|
            # There is likely some fancy, bit-wise math that can do this
            bits = byte.to_s(2).rjust(8, '0')
            bits[-1] = bits[-1] == "0" ? "1" : "0"
            bits.to_i(2)
          end
          value.bytes.map do |byte|
            byte.to_s(2).count('1').odd? ? byte : flip_low_order_bit.call(byte)
          end&.pack('C*')
        end

        # Encrypt the ‘Key Block’ with the ‘derived 3DES KEK’ using 3DES-CBC (IV=0).
        # E^Derived3DESKEK(‘Random’ + ‘decrypted MWK’ + ‘CheckValue’) to create a binary encrypted key block
        # (40 bytes). The result is the ‘encrypted Key Block’.
        def encrypted_key_block
          cipher = OpenSSL::Cipher.new(ENCRYPTION_ALGORITHM)
          cipher.encrypt
          cipher.padding = 0
          cipher.key = derived_3des_kek
          cipher.iv = zeros
          cipher.update(key_block)
        end

        # Concatenate the ‘Random’+'MWK'+’CheckValue’ to create a 40 byte key block.
        def key_block
          bl = []
          bl << random_bytes(8).bytes
          bl << merchant_working_key.bytes
          bl << check_value.bytes
          bl.flatten.pack('C*')
        end

        # Encrypt an 8-byte block of zeroes with ‘decrypted MWK’
        def check_value
          cipher = OpenSSL::Cipher.new(ENCRYPTION_ALGORITHM)
          cipher.encrypt
          cipher.padding = 0
          cipher.iv = zeros
          cipher.key = merchant_working_key
          cipher.update(zeros)
        end
    end
  end
end
