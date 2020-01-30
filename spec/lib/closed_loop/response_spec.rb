describe ClosedLoop::Response do
  context 'successful response' do
    subject { described_class.new(first_data_response('closed_loop/activate_card_success.xml')) }

    it { expect(subject.success?).to be true }
    it { expect(subject.failure?).to be false }
    it { expect(subject.error_message).not_to be_present }

    describe '.fields' do
      it { expect(subject.fields).to be_a Hash }
      it { expect(subject.fields).to include(merchant_id: "102617", authorization_code: "748245", response_code: "00", previous_balance: "0", echo: "Taco", card_class: "0", lock_amount: "0", local_currency: "840") }
    end
  end

  context 'un-successful response' do
    subject { described_class.new(first_data_response('closed_loop/activate_card_failure.xml')) }
    it { expect(subject.success?).to be false }
    it { expect(subject.failure?).to be true }
    it { expect(subject.error_message).to eq 'Invalid transaction code.' }

    context 'unknown error code' do
      subject { described_class.new(first_data_response('closed_loop/datawire_unknown_error_code.xml')) }
      xit 'raises Errno::EHOSTDOWN with unknown codes' do
        expect { subject }.to raise_error(Errno::EHOSTDOWN)
      end
    end
  end

  context 'successful response with failing/timeout code' do
    subject { described_class.new(first_data_response('closed_loop/datawire_success_with_205_timeout.xml')) }
    it { expect { subject }.to raise_error(Faraday::TimeoutError) }
  end
end
