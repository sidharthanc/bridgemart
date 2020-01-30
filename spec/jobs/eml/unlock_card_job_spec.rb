describe EML::UnlockCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/unlocks} }

    it 'unlocks the card via EML' do
      webmock :post, url => 'eml/POST_locks.201.json'
      subject.perform code
      expect(WebMock).to have_requested(:post, url).with body: hash_including(note: EML::UnlockCardJob::NOTE)
    end

    it 'passes a card to the activated callback' do
      webmock :post, url => 'eml/POST_unlocks.201.json'
      expect(code).to receive(:registered)
      subject.perform code
    end

    context 'API failed' do
      it 'does not call the unlocked callback' do
        webmock :post, url => 'eml/error.500.json'
        expect(code).to_not receive(:unlocked)
        expect do
          subject.perform code
        end.to raise_error(EML::Error)
      end
    end
  end
end
