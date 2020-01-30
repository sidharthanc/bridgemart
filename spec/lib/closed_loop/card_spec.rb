describe ClosedLoop::Card do
  subject { described_class.from_code(code) }
  before do
    allow(Codes::GenerateCodePdfJob).to receive(:perform_now).and_return(true)
    allow(FirstData::Client).to receive(:service_url).and_return("https://staging2.datawire.net/sd")
  end

  describe '.activate', vcr: { cassette_name: 'closed_loop/card/activate' } do
    let(:code) { create(:code, limit_cents: 50_00) }
    it 'updates the card to activated' do
      expect { subject.activate }.to change { code.reload.status }.to 'activated'
    end
    it 'updates the balance correctly' do
      code.update(balance: nil)
      expect { subject.activate }.to change(code.reload, :balance).to 50.00.to_money
    end
    it 'updates the card_number and pin' do
      expect { subject.activate }.to change(code.reload, :card_number)
    end
    it 'updates the external account number' do
      expect { subject.activate }.to change(code.reload, :extended_account_number)
    end
  end

  describe '.lock', vcr: { cassette_name: 'closed_loop/card/lock' } do
    let(:code) { create(:code, :activated, limit_cents: 50_00) }
    it 'updates the card to locked' do
      expect { subject.lock 'testing' }.to change { code.reload.status }.to 'locked'
    end
  end

  describe '.unload' do
    context 'with invalid amount', vcr: { cassette_name: 'closed_loop/card/unload' } do
      let(:code) { create(:code, :activated, limit_cents: 50_00) }
      it "ignores invalid amounts, closes the card anyways with the proper amount" do
        expect { subject.unload(77.00.to_money) }.to change(code.reload, :balance).to(0)
                                                                                  .and change(code.member.organization.reload, :credit_total).by(50.to_money)
      end
    end
    context 'with valid amount', vcr: { cassette_name: 'closed_loop/card/unload' } do
      let(:code) { create(:code, :activated, limit_cents: 50_00) }
      fit 'unloads value from card and returns it to organization' do
        expect { subject.unload(50.00.to_money) }
          .to change(code.reload, :balance).to(0)
                                           .and change(code.reload, :unloaded_amount).to(50.to_money)
                                                                                     .and change(code.member.organization.reload, :credit_total).by(50.to_money)
      end
    end
  end
end
