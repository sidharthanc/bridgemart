describe EML::UnloadCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/unload} }

    it 'unloads the amount via EML' do
      webmock :post, url => 'eml/POST_unload.201.json'
      subject.perform code, 10.00
      expect(WebMock).to have_requested(:post, url).with body: hash_including(amount: 10.00, note: 'Unload $10.00')
    end

    it 'passes the amount unloaded to the unloaded callback' do
      webmock :post, url => 'eml/POST_unload.201.json'
      expect(code).to receive(:unloaded).with 10.to_money
      subject.perform code, 10.00
    end

    context 'API failed' do
      it 'raises an EML::Error' do
        webmock :post, url => 'eml/error.500.json'
        expect { subject.perform code, 10.00 }.to raise_error(EML::Error)
      end

      it 'does not call the unloaded callback' do
        webmock :post, url => 'eml/error.500.json'
        expect(code).to_not receive(:unloaded)
        expect { subject.perform code, 10.00 }.to raise_error(EML::Error)
      end
    end
  end
end
