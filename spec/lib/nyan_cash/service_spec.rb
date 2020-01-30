describe NyanCash::Service do
  let(:virtual_card) { VirtualCard.new(nyan_cash_card.to_h) }

  describe '#activate' do
    subject { described_class.new.activate(5_00) }
    it { is_expected.to have_attributes({ balance: Money.new(5_00), closed_at: nil }.stringify_keys) }
  end

  describe '#lock' do
    context 'existing card' do
      let(:virtual_card) { NyanCash::Service.new.activate(5_00) }
      subject { described_class.new.lock(virtual_card) }

      it 'marks via timestamp' do
        expect(subject.locked_at).to be_present
      end
    end
    # context 'card not found'
  end

  describe '#unlock' do
    context 'existing card' do
      let(:virtual_card) { NyanCash::Service.new.activate(5_00) }
      subject { described_class.new.unlock(virtual_card) }

      context 'that is locked' do
        before { described_class.new.lock(virtual_card) }
        it 'marks via timestamp' do
          expect(subject.locked_at).to be_nil
        end
      end
    end
    # context 'card not found'
  end

  describe '#close' do
    context 'existing card' do
      let(:virtual_card) { NyanCash::Service.new.activate(5_00) }
      subject { described_class.new.close(virtual_card) }

      it 'marks via timestamp' do
        expect(subject.closed_at).to be_present
      end
    end
  end
end
