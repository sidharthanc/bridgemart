RSpec.describe Code, type: :model do
  subject { build(:code) }
  let(:code) { build(:code) }
  let(:card) { Struct.new(:id, :balance, :status, :fields, :pan) }
  let(:order) { code.order }

  # Shared spec is super flakey
  xdescribe 'Deactivatable' do
    subject { create(:code, :activated) }

    it_has_behavior 'deactivatable'
  end

  it { is_expected.to be_auditable }
  it { is_expected.to have_many(:credits) }
  it { is_expected.to respond_to(:redemption_instructions) }
  it { is_expected.to have_db_column(:uuid) }

  it 'restrict unique legacy_identifiers values' do
    subject.update_attribute(:legacy_identifier, 12_345)
    expect { code.update_attribute(:legacy_identifier, 12_345) }.to raise_error ActiveRecord::RecordNotUnique
  end

  it 'allow multiple nil legacy_identifier values' do
    subject.update_attribute(:legacy_identifier, nil)
    expect { code.update_attribute(:legacy_identifier, nil) }.not_to raise_error
  end

  describe 'VirtualCard (Atttributes)' do
    subject(:code) { build(:code, :activated) }
    describe '#pin' do
      it { expect(code.pin).to be_present }
    end
    describe '#card_number' do
      it { expect(code.card_number).to be_present }
    end
  end

  describe 'Status Delegation' do
    subject { create(:code) }
    let(:product_category) { double("Product Category") }

    before { ActiveJob::Base.queue_adapter = :test } # does this persist?

    describe '#card_provider' do
      before { expect(subject).to receive(:product_category).and_return(product_category).at_least(:once) }

      context "eml" do
        before { expect(product_category).to receive(:card_type).and_return('eml').at_least(:once) }
        it { expect(subject.card_provider).to be_a EML::Card }
      end
      context "first_data" do
        before { expect(product_category).to receive(:card_type).and_return('first_data').at_least(:once) }
        it { expect(subject.card_provider).to be_a ClosedLoop::Card }
      end
    end

    describe '#activate' do
      it 'delegates to Cards::ActivateJob' do
        expect { subject.activate }.to have_enqueued_job(Cards::ActivateJob).with(subject)
      end
    end

    describe '#register' do
      it 'delegates to Cards::RegisterJob' do
        expect { subject.register }.to have_enqueued_job(Cards::RegisterJob).with(subject)
      end
    end

    describe '#unload' do
      it 'delegates to Cards::UnloadJob if balance_cents zero or pin blank or external_id blank' do
        expect { subject.unload 10.to_money }.not_to have_enqueued_job(Cards::UnloadJob).with(subject, '10.00')
      end
    end

    describe '#lock' do
      it 'delegates to Cards::LockJob' do
        expect { subject.lock 'test' }.to have_enqueued_job(Cards::LockJob).with(subject, 'test')
      end
    end

    describe '#unlock' do
      it 'delegates to Cards::UnlockJob' do
        expect { subject.unlock 'test' }.to have_enqueued_job(Cards::UnlockJob).with(subject, 'test')
      end
    end
  end

  describe '#status' do
    it 'is initially in the generated state' do
      expect(subject).to be_generated
    end
  end

  describe '#activated' do
    let(:code) { create(:code, :activated) }
    before { allow(Codes::GenerateCodePdfJob).to receive(:perform_now).and_return(true) }
    it 'updates the card external ID and balance' do
      subject.activated card.new('test', 20.0)
      expect(subject.external_id).to eq 'test'
      expect(subject.balance).to eq 20.to_money
    end

    it 'sets the status to activated' do
      subject.activated card.new('test', 0)
      expect(subject).to be_activated
    end

    it 'broadcast code_activation_success' do
      expect { subject.activated(card.new('test', 0)) }.to broadcast(:code_activation_success)
    end

    it 'enqueue GenerateCodePdfJob on_code_activation_success' do
      expect { code.on_code_activation_success(code)}.to enqueue_job(Codes::GenerateCodePdfJob)
    end
  end

  describe '#deactivate' do
    subject { codes(:kaleb) }

    it 'not unloads the card balance no pin , no external_id' do
      subject.balance = 10.to_money
      subject.update pin:'',external_id:''
      subject.deactivate
      expect { subject.unload 10.to_money }.not_to have_enqueued_job(Cards::UnloadJob).with(subject, '10.00')
    end
  end

  describe '#deactivate' do
    subject { codes(:kaleb) }

    it 'not unloads the card balance already code deactivated' do
      subject.balance = 10.to_money
      subject.update deactivated_at:Time.now
      subject.deactivate
      expect { subject.unload 10.to_money }.not_to have_enqueued_job(Cards::UnloadJob).with(subject, '10.00')
    end
  end


  describe 'unloaded first_data codes' do
    subject { codes(:kaleb) }
    let(:organization) { subject.member.organization }

    it 'add the credit back if unload the balance' do
     organization.credit_pool(amount: 250, source: organization)
     subject.balance = 10.to_money
     subject.unloaded 10.to_money
     expect(organization.credit_total).to eq 260.to_money
   end
  end

  describe '#deactivate' do
    subject { codes(:logan) }

    it 'unloads the card balance' do
      subject.balance = 10.to_money
      expect(subject).to receive(:unload).with(10.to_money)
      subject.deactivate
    end
  end

  describe '#unloaded' do
    subject { codes(:logan) }
    let(:organization) { subject.member.organization }

    it 'subtracts the unloaded amount from the card' do
      subject.balance = 10.to_money
      expect do
        expect { subject.unloaded 5.to_money }.to change(subject, :balance).to 5.to_money
      end.to change(Credit, :count).by(1)
      expect(Credit.last.amount).to eq 5.to_money
    end

    it 'does not subtract below zero' do
      subject.balance = 10.to_money
      subject.unloaded 10.to_money
      subject.unloaded 10.to_money
      expect(subject.balance).to be_zero
      expect(Credit.last.amount).to eq 10.to_money
    end

    it 'should update unloaded_amount_cents after transferring' do
      subject.balance = 10.to_money
      subject.unloaded 10.to_money
      expect(subject.unloaded_amount).to eq 10.to_money
    end

    context 'Credit Pool credit' do
      it 'credits the Organization' do
        expect { subject.unloaded 100.to_money }.to change(Credit, :count).by(1)
        expect(subject.member.organization.credits).to match_array [Credit.last]
        credit = organization.credits.first
        expect(credit.amount).to eq 100.to_money
        expect(credit.organization).to eq organization
      end
    end
  end

  describe '#registered' do
    subject { codes(:logan) }

    it 'sets the status to activated' do
      subject.registered
      expect(subject).to be_registered
    end

    # Module Shifted
    xit 'should send an email to the member' do
      expect { subject.registered }.to enqueue_job(ActionMailer::DeliveryJob).with('CodeMailer', 'registered_email', 'deliver_now', subject.member)
    end
  end

  describe '#locked' do
    subject { codes(:logan) }

    it 'sets the status to locked' do
      subject.locked
      expect(subject).to be_locked
    end
  end

  describe 'authentication token' do
    subject { described_class.new }
    it 'generates an auth token when validated' do
      expect { subject.valid? }.to change { subject.authentication_token }.from nil
    end
  end

  context '#at_or_past_expiration' do
    let(:code) { codes(:logan) }

    it 'returns no expired codes' do
      expect(Code.at_or_past_expiration).to be_empty

      code.update created_at: 366.days.ago, deactivated_at: DateTime.now

      expect(Code.at_or_past_expiration).to be_empty
    end

    it 'returns an expired code' do
      # code.order.update ends_on: 366.days.ago
      order.ends_on = 366.days.ago
      order.save(validate: false)
      expect(Code.at_or_past_expiration).to be_present
    end
  end

  context '#expiration_date' do
    subject { codes(:logan) }

    it 'uses the order ends_on date' do
      subject.update(expires_on: subject.order.ends_on)
      expect(subject.expiration_date).to eq I18n.l(subject.order.ends_on, format: :mmddyyyy)
    end
  end

  context '#extended_account_number', legacy: true do
    subject { codes(:kaleb) }

    it 'is an empty string for an absent EAN' do
      subject.update! fields: { extended_account_number: nil }
      expect(subject.extended_account_number).to be_blank
    end

    it 'extracts the EAN from the fields attribute' do
      subject.update! fields: { extended_account_number: FirstData::Encryption.encrypt_ean('1234') }
      expect(subject.reload.extended_account_number).to eq '1234'
    end
  end

  context '#show_organization_logo' do
    subject { codes(:kaleb) }

    it 'should not show organization logo by default' do
      expect(subject.show_organization_logo?).to be false
    end

    it 'should show organization logo when conditions are met' do
      attach_test_image(subject.product_category)
      subject.product_category.update! use_organization_branding: true
      subject.organization.logo.attach io: File.open(Rails.root.join('app', 'assets', 'images', 'missing-image.png')), filename: 'missing-image.png'
      expect(subject.show_organization_logo?).to be true
    end

    it 'should not show org logo when it is not present' do
      attach_test_image(subject.product_category)
      subject.product_category.update! use_organization_branding: true
      expect(subject.show_organization_logo?).to be false
    end
  end

  context '#card_number_formatted' do
    it 'formats a short sequence in sections of 4' do
      subject.external_id = '123'
      expect(subject.card_number_formatted).to eq '123'
    end

    it 'formats a long sequence in sections of 4' do
      subject.external_id = '6134097735793899'
      expect(subject.card_number_formatted).to eq '6134 0977 3579 3899'
    end

    it 'formats an uneven long sequence in sections of 4' do
      subject.external_id = '613409773579389'
      expect(subject.card_number_formatted).to eq '6134 0977 3579 389'
    end

    it 'returns an empty string if sequence is empty' do
      subject.external_id = ''
      expect(subject.card_number_formatted).to be_blank
    end

    it 'returns an empty string if sequence is nil' do
      subject.external_id = nil
      expect(subject.card_number_formatted).to be_blank
    end
  end

  context 'scopes' do
    let(:first_data_code) { codes(:kaleb) }
    let(:eml_code_one) { codes(:logan) }
    let(:eml_code_two) { codes(:angelita) }

    # :active is already defined by the Deactivatable class, use :unexpired to find current and unexpired codes
    context ':unexpired' do
      it { expect(described_class.unexpired.count).to eq 3 }
      it { expect(described_class.unexpired.with_card_type(:first_data)).to eq [first_data_code] }
      it { expect(described_class.unexpired.with_card_type(:eml)).to match_array [eml_code_one, eml_code_two] }
    end

    it ':active_eml'
    it ':active_first_data'
  end
end
