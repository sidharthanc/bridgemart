RSpec.describe EML::CardOneTimeUrlsJob do
  let(:code) { codes(:logan) }
  let(:url) { %r{cards/#{code.card_number}} }

  describe 'perform' do
    it 'pulls down the barcode/card image from the EML API' do
      webmock :get, url => 'eml/GET_card_barcode.200.json'
      subject.perform code
      expect(WebMock).to have_requested(:get, url).with body: hash_including(fields: 'barcode_image,card_image')
    end

    it 'stores the barcode/card image URLs on the code record' do
      webmock :get, url => 'eml/GET_card_barcode.200.json'
      expect do
        subject.perform code
      end.to change {
        code.reload
        [code.barcode_url, code.card_image_url]
      }
    end

    it 'appends the correct barcode content type to the barcode image URL' do
      webmock :get, url => 'eml/GET_card_barcode.200.json'
      subject.perform code
      expect(code.reload.barcode_url).to eq 'http://barcode?barcodeContentType=NONE'
    end
  end
end
