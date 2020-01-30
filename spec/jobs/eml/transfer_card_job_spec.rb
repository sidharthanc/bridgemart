describe EML::TransferCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/transfer} }

    it 'transfers the card via EML' do
      webmock :get, %r{cards/#{code.card_number}} => 'eml/GET_card.200.json', with: { body: hash_including(fields: 'activating_merchant_group_name') }
      webmock :post, url => 'eml/POST_transfer.201.json'

      subject.perform code, 'Test Note'
      expect(WebMock).to have_requested(:post, url).with body: hash_including(
        note: 'Test Note',
        tocardtype: 2,
        location: { name: 'Metova' }
      )
    end

    context 'Successful transfer' do
      before do
        webmock :get, %r{cards/#{code.card_number}} => 'eml/GET_card.200.json'
        webmock :post, url => 'eml/POST_transfer.201.json'
      end

      it 'creates a new Code record with the transferred card details' do
        expect { subject.perform code, 'Test Note' }.to change(Code, :count).by 1

        Code.last.tap do |new_code|
          expect(new_code.member).to eq code.member
          expect(new_code).to be_registered
          expect(new_code.limit).to eq code.limit
          expect(new_code.balance).to eq 50.to_money
          expect(new_code.card_number).to eq 'TRANSFER123'
          expect(new_code.plan_product_category).to eq code.plan_product_category
        end
      end

      it 'mails the code to the member' do
        expect { subject.perform code, 'Test Note' }.to enqueue_job(ActionMailer::DeliveryJob).with('CodeMailer', 'registered_email', 'deliver_now', code.member)
      end
    end

    context 'API failed' do
      it 'does not call the transfer API if the API to get the location name fails' do
        webmock :get, %r{cards/#{code.card_number}} => 'eml/error.500.json'
        expect { subject.perform code, 'Test Note' }.to raise_error(EML::Error)
        expect(WebMock).to_not have_requested(:post, url)
      end

      it 'does not create a new Code' do
        webmock :get, %r{cards/#{code.card_number}} => 'eml/GET_card.200.json'
        webmock :post, url => 'eml/error.500.json'
        expect do
          expect { subject.perform code, 'Test Note' }.to raise_error(EML::Error)
        end.to_not change(Code, :count)
      end
    end
  end
end
