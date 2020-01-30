describe EML::Card do
  let(:code) { codes(:logan) }
  subject(:card) { described_class.from_code code }

  describe '#activate' do
    before do
      code.balance = 0
      stub_request(:post, "https://webservices.xtest.storefinancial.net/api/v1/en/cards/new/activations?fields=all,pan&program=BridgeM197&search_parameter=ExternalId")
        .to_return(status: 200, body: { id: "888777", available_balance: '75.00' , pan: '123456' }.to_json)
      allow(Codes::GenerateCodePdfJob).to receive(:perform_now).and_return(true)
    end
    it do
      expect(code).to receive(:register)
      expect { card.activate }
        .to change { code.reload.status }.to('activated')
                                         .and change { code.reload.external_id }.to('888777')
                                                                                .and change { code.reload.balance }.to('75.00'.to_money)
    end
  end

  describe '#register' do
    before do
      stub_request(:post, "https://webservices.xtest.storefinancial.net/api/v1/en/cards/LOGAN_CODE/register?fields=all,pan&program=BridgeM197&search_parameter=ExternalId")
        .to_return(status: 200, body: {}.to_json)
    end
    it do
      expect { card.register }
        .to change { code.reload.status }.to('registered')
    end
  end

  describe '#lock' do
    before do
      stub_request(:post, "https://webservices.xtest.storefinancial.net/api/v1/en/cards/LOGAN_CODE/locks?fields=all,pan&program=BridgeM197&search_parameter=ExternalId")
        .to_return(status: 200, body: {}.to_json)
    end
    it do
      expect { card.lock 'testing' }
        .to change { code.reload.status }.to('locked')
    end
  end

  describe '#unlock' do
    before do
      stub_request(:post, "https://webservices.xtest.storefinancial.net/api/v1/en/cards/LOGAN_CODE/unlocks?fields=all,pan&program=BridgeM197&search_parameter=ExternalId")
        .to_return(status: 200, body: {}.to_json)
    end
    it do
      expect { card.unlock 'testing' }
        .to change { code.reload.status }.to('registered')
    end
  end

  describe '#unload' do
    before do
      stub_request(:post, "https://webservices.xtest.storefinancial.net/api/v1/en/cards/LOGAN_CODE/unload?program=BridgeM197&search_parameter=ExternalId")
        .to_return(status: 200, body: {}.to_json)
    end
    it do
      expect { card.unload 50 }
        .to change { code.reload.balance }.to(0)
                                          .and change { code.unloaded_amount }.to(50.to_money)
                                                                              .and change { code.member.organization.credit_total }.by(50.to_money)
    end
  end
end
