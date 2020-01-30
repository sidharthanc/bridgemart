describe EML::LockCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/locks} }

    it 'locks the card via EML' do
      webmock :post, url => 'eml/POST_locks.201.json'
      subject.perform code, 'damaged'
      expect(WebMock).to have_requested(:post, url).with body: hash_including(note: EML::LockCardJob::NOTE, reason: 'Damaged')
    end

    it 'passes a card to the activated callback' do
      webmock :post, url => 'eml/POST_locks.201.json'
      expect(code).to receive(:locked)
      subject.perform code, 'damaged'
    end

    %i[damaged office_error expired unclaimed misc].each do |reason|
      it 'does not automatically transfer the card' do
        webmock :post, url => 'eml/POST_locks.201.json'
        expect(EML::TransferCardJob).to_not receive(:perform_now)
        subject.perform code, reason
      end
    end

    # Functionality Removed
    xit 'automatically transfers the card when lost' do
      webmock :post, url => 'eml/POST_locks.201.json'
      expect(EML::TransferCardJob).to receive(:perform_now).with(code, 'Lost')
      expect(subject).not_to receive(:post)
      subject.perform code, 'lost'
    end

    # Functionality Removed
    xit 'automatically transfers the card when stolen' do
      webmock :post, url => 'eml/POST_locks.201.json'
      expect(EML::TransferCardJob).to receive(:perform_now).with(code, 'Stolen')
      expect(subject).not_to receive(:post)
      subject.perform code, :stolen
    end

    context 'API failed' do
      it 'does not call the locked callback' do
        webmock :post, url => 'eml/error.500.json'
        expect(code).to_not receive(:locked)
        expect do
          subject.perform code, 'damaged'
        end.to raise_error(EML::Error)
      end
    end
  end
end
