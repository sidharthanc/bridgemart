describe FirstData::Encryption do
  subject { described_class }

  let(:working_key) { "5b70649d4ae0bf2af891c167514aa7515b70649d4ae0bf2a" }
  before do
    allow(FirstData::Client).to receive(:credentials).and_return(merchant_working_key: working_key)
  end

  describe '.generate_key' do
    it { expect(subject.generate_key_pair).to include(:private, :public, :shared) }
  end
  describe '.generate_merchant_working_key' do
    let(:shared_secret) { "SOMEVERYLONGHEXSTRING" }
    it { expect(subject.generate_merchant_working_key(shared_secret)).to include(:merchant_key, :merchant_key_encrypted) }
  end

  describe '.decrypt_ean' do
    encrypted_value = "76db821f5c7af12dc8d70a6a79cfcb77"
    it 'decrypts the data given with the merchant key' do
      expect(subject.decrypt_ean(encrypted_value)).to eq "33053083"
    end
  end
  describe '.encrypt_ean' do
    decrypted_value = "33053083"
    let(:expected_encrypted_value) { subject.bin_to_hex("\x76\xdb\x82\x1f\x5c\x7a\xf1\x2d\xc8\xd7\x0a\x6a\x79\xcf\xcb\x77") }
    before do
      expect(subject).to receive(:random_bytes).with(7).and_return "\x95\xe4\xd7\x7c\x6d\x6c\x6c".b
    end
    it 'encrypts the value' do
      expect(subject.encrypt_ean(decrypted_value)).to eq expected_encrypted_value
    end
  end
  # Sanity check, should be bi-directional
  it { expect(subject.decrypt_ean(subject.encrypt_ean("5533")).strip). to eq "5533" }

  describe '.ean_block(value)' do
    value = "33053083"
    before { expect(subject).to receive(:random_bytes).with(7).and_return "\x95\xe4\xd7\x7c\x6d\x6c\x6c".b }
    it { expect(subject.ean_block(value).b).to eq "\x95\xe4\xd7\x7c\x6d\x6c\x6c\x99\x33\x33\x30\x35\x33\x30\x38\x33".b }
  end
  describe 'Helpers' do
    describe '#checksum' do
      value = "33053083"
      it { expect(subject.checksum(value).b).to eq "\x99".b }
    end
    describe 'zeros' do
      it { expect(subject.zeros.bytes.size).to eq 8 }
      it { expect(subject.zeros).to eq "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000" }
    end
  end
end
