describe VirtualCard, type: :model do

  class InvalidProvider
  end

  describe '#provider / #provider_service' do
    it 'raises exception if missing/invalid' do
      vcard = VirtualCard.new(provider: "InvalidProvider")
      expect { vcard.provider_service }.to raise_error VirtualCard::InvalidProviderError
    end
  end

  describe '#balance' do
   # The custom setters/getters for this attribute make using these shoulda matchers very difficult right now
   # it { is_expected.to validate_numericality_of(:balance).only_integer }
   # it { is_expected.to validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }

    it 'converts the balance to a money object' do
      vcard = VirtualCard.new(balance: 1090)
      expect(vcard.balance).to be_a Money
      expect(vcard.balance.send(:format)).to eq '$10.90'
    end
    it 'allows setting with money object' do
      vcard = VirtualCard.new(balance: Money.new(4250))
      expect(vcard.balance).to be_a Money
      expect(vcard.balance.send(:format)).to eq '$42.50'
    end
  end
end
