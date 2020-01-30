describe FirstData::Encryption::MerchantKeyGenerator do
  include FirstData::Encryption::Helpers
  let(:shared_secret) { "834a9d0434d817735589f22a4633fb6dd3e530dba1ea2bbb9e1accb438084513087f5da00ea86ed53164d8893b81a9c8df65bc189cf6830d271e1a3e504cbcb25714164b519c75f6e0adf41bb07e7f8c4fb7b9960d813e6577a73252eea9c139cdda606d51122170e71636e7849149618c8238a226128821f0b668490bdca82f" }
  let(:working_key) { "5b70649d4ae0bf2af891c167514aa7515b70649d4ae0bf2a" }
  let(:encrypted_working_key) { "39cf6c24b3d5c90a6cf306db213ef99286e6eb44c00fa2270b6efd3d582d1020070d916cc383b8dd" }
  subject(:key_gen) { described_class.new(shared_secret) }

  before do
    # There are 2 random values used, one in the MWK (random_seed) and another in the encryption process
    # The first is reused, albeit indirectly, in the encryption process as well, hence why one gets a helper method
    allow_any_instance_of(FirstData::Encryption::MerchantKeyGenerator).to receive(:random_seed).and_return(hex_to_bin("5a70649c4ae0bf2bf891c067504aa751"))
    allow_any_instance_of(FirstData::Encryption::MerchantKeyGenerator).to receive(:random_bytes).with(8).and_return(hex_to_bin("e711eaffa0cac3ba"))
  end

  it { expect(subject.merchant_working_key.bytes.size).to eq 24 }
  it { expect(bin_to_hex(subject.merchant_working_key)).to eq working_key }

  it { expect(subject.merchant_working_key_encrypted.bytes.size).to eq 80 }
  it { expect(subject.merchant_working_key_encrypted).to eq encrypted_working_key }

  describe 'Private Methods' do
    subject { described_class.new(shared_secret) }
    describe '#kek [private]' do
      let(:kek) { "215e10aad0bdcf7b34d317a236b81139" }
      it { expect(subject.send(:kek)).to eq hex_to_bin(kek) }
    end
    describe '#derived_3des_kek [private]' do
      let(:derived_3des_kek) { "205e10abd0bcce7a34d316a237b91038205e10abd0bcce7a" }
      it { expect(subject.send(:derived_3des_kek)).to eq hex_to_bin(derived_3des_kek) }
      it { expect(subject.send(:derived_3des_kek).bytes.size).to eq 24 }
    end
    describe '#detect_and_correct_odd_parity [private]' do
      let(:original_value) { hex_to_bin("215e10aad0bdcf7b34d317a236b81139215e10aad0bdcf7b") }
      let(:odd_parity_corrected_value) { hex_to_bin("205e10abd0bcce7a34d316a237b91038205e10abd0bcce7a") }
      it 'corrects odd_parity byte for byte' do
        expect(subject.send(:detect_and_correct_odd_parity, original_value)).to eq odd_parity_corrected_value
      end
    end
    describe '#revise [private]' do
      let(:value) { hex_to_bin("215e10aad0bdcf7b34d317a236b81139") }
      let(:revised_value) { hex_to_bin("215e10aad0bdcf7b34d317a236b81139215e10aad0bdcf7b") }
      it 'appends to first 8 bytes to the value, returning the value' do
        expect(subject.send(:revise, value)).to eq revised_value
      end
    end
    describe '.check_value [private]' do
      it { expect(subject.send(:check_value)).to eq hex_to_bin("17815b6c54a3c172") }
      it { expect(subject.send(:check_value).bytes.size).to eq 8 }
    end
    describe '.key_block [private]' do
      let(:key_block) { "e711eaffa0cac3ba5b70649d4ae0bf2af891c167514aa7515b70649d4ae0bf2a17815b6c54a3c172" }
      it { expect(subject.send(:key_block).bytes.size).to eq 40 }
      it { expect(subject.send(:key_block)).to eq hex_to_bin(key_block) }
    end
    describe '.encrypted_key_block [private]' do
      let(:key_block) { "e711eaffa0cac3ba5b70649d4ae0bf2af891c167514aa7515b70649d4ae0bf2a17815b6c54a3c172" }
      let(:derived_3des_kek) { "205e10abd0bcce7a34d316a237b91038205e10abd0bcce7a" }
      let(:encrypted_key_block) { "39cf6c24b3d5c90a6cf306db213ef99286e6eb44c00fa2270b6efd3d582d1020070d916cc383b8dd" }
      before do
        expect(subject).to receive(:key_block).and_return(hex_to_bin(key_block))
        expect(subject).to receive(:derived_3des_kek).and_return(hex_to_bin(derived_3des_kek))
      end
      it { expect(subject.send(:encrypted_key_block).bytes.size).to eq 40 }
      it { expect(subject.send(:encrypted_key_block)).to eq hex_to_bin(encrypted_key_block) }
    end
  end
end
