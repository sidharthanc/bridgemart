describe EML::ActivateCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/new/activations} }
    before { allow(Codes::GenerateCodePdfJob).to receive(:perform_now).and_return(true) }

    it 'activates the card via EML' do
      webmock :post, url => 'eml/POST_activations.201.json'
      subject.perform code
      expect(WebMock).to have_requested(:post, url).with body: hash_including(amount: '50.0')
    end

    it 'sets the card status to activating' do
      webmock :post, url => 'eml/POST_activations.201.json'
      expect(code).to receive(:activated).with(kind_of(EML::Card))
      subject.perform code
      expect(code.reload).to be_activating
    end

    it 'passes a card to the activated callback' do
      webmock :post, url => 'eml/POST_activations.201.json'
      expect(code).to receive(:activated).with(kind_of(EML::Card)) { |card| card }
      card = subject.perform code
      expect(card.id).to eq 'TESTCARD123'
      expect(card.balance).to eq 50.0
    end
  end
end
