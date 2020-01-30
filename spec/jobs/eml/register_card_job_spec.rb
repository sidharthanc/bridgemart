describe EML::RegisterCardJob do
  describe 'perform' do
    let(:code) { codes(:logan) }
    let(:url) { %r{cards/#{code.card_number}/register} }
    let(:member) { members(:logan) }
    let(:member_address) { addresses(:logan) }

    it 'registers the card via EML' do
      webmock :post, url => 'eml/POST_registrations.201.json'
      subject.perform code
      expect(WebMock).to have_requested(:post, url).with body: hash_including(
        first_name: member.first_name,
        last_name: member.last_name,
        address1: member_address.street1,
        city: member_address.city,
        state: member_address.state,
        postal_code: member_address.zip,
        country: 'USA',
        email: member.email
      )
    end

    it 'uses the proper search_parameter and program in the URL' do
      webmock :post, url => 'eml/POST_registrations.201.json'
      subject.perform code
      expect(WebMock).to have_requested(:post, url).with query: hash_including(program: EML::Client::PROGRAM, search_parameter: 'ExternalId')
    end

    it 'calls the registered callback' do
      webmock :post, url => 'eml/POST_registrations.201.json'
      expect(code).to receive(:registered)
      subject.perform code
    end

    # Module Shifted
    xit 'mails the code to the member' do
      webmock :post, url => 'eml/POST_registrations.201.json'
      expect { subject.perform code }.to enqueue_job(ActionMailer::DeliveryJob).with('CodeMailer', 'registered_email', 'deliver_now', code.member)
    end

    # Module Shifted
    xit 'marks the code as being delivered' do
      webmock :post, url => 'eml/POST_registrations.201.json'
      expect { subject.perform code }.to change { code.reload.delivered }.from(false).to true
    end

    context 'API fails' do
      it 'does not call the registered callback' do
        webmock :post, url => 'eml/error.500.json'
        expect(code).to_not receive(:registered)
        expect do
          subject.perform code
        end.to raise_error(EML::Error)
      end
    end
  end
end
