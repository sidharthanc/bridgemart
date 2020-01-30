describe FirstData::Encryption::KeyGenerator do
  it { expect(subject.private_key).to be_present }
  it { expect(subject.public_key).to be_present }
  it { expect(subject.shared_secret).to be_present }

  describe 'shared_secret' do
    pending "I don't _think_ these are predictable and therefore testable."
    let(:private_key) { "5e8b02f2b2e9c96e0c359ecd14eb1b29ebdd61e70a61e42f0836a5974963e96d91f1462b699c222bc92bc068e9dce5c78e4349d28ddcb6d0ed2c41f7cd8af2418c8ae27b6909484ded7f0c5b4c286d9c36518fa5953974741b3a6f757b59a41a5ca0b74efd919bb7ed8ccec9cb3bc4b4f8d15d16dc4642e54691904b2f35b969" }
    let(:public_key)  { "85f04dd00345642ad12b65bd1a7c38728bff0b8e281ddb6ac4f2739e82a02145daabf23d173c933913b1f844059710e9125591569de427eae1d269accbfa3305069deb7622d1da3ad9820d11bd24fdcce5381d2df99bda314394738dfcbe210eae247b1303e79297ff746cd919e189f6a5776e6ecc24c8900de0f38f159072de" }
    let(:fd_pub_key) { "71257ba7758cde21480706ca55861f5fe6122e5b879420 80f3e384890284fd62341b90a1b60fb44add61031d6aac 3d5b267f1435b0765ac289040b63b242eed82863fd18bb 637757edf44ba4589e0ce99d192e902c16ef1a89e7e7c1 c2eb5a6a8ab3e3e4f6b8a9cacca4b8f6c4e20d12626797 5406cf9151d57beeae32c33cd8" }
    let(:expected_shared_secret) { "834a9d0434d817735589f22a4633fb6dd3e530dba1ea2bbb9e1accb438084513087f5da00ea86ed53164d8893b81a9c8df65bc189cf6830d271e1a3e504cbcb25714164b519c75f6e0adf41bb07e7f8c4fb7b9960d813e6577a73252eea9c139cdda606d51122170e71636e7849149618c8238a226128821f0b668490bdca82f" }

    before do
      subject.send(:dh).set_key(OpenSSL::BN.new(public_key, 16), OpenSSL::BN.new(private_key, 16))
      expect(subject).to receive(:first_data_public_key).and_return(fd_pub_key)
    end
    xit { expect(subject.shared_secret).to eq expected_shared_secret }
  end

  describe 'dh [private]' do
    it "prime is configured as required" do
      expect(subject.send(:dh).p).to be_a OpenSSL::BN
    end
    it "generator is configured as required" do
      expect(subject.send(:dh).g).to eq 5
    end
  end
end
