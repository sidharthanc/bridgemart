shared_context 'deactivatable' do
  include ActiveSupport::Testing::TimeHelpers
  describe '#deactivate' do
    it 'sets deactivated_at to the current time' do
      freeze_time do
        expect { subject.deactivate }.to change(subject.reload, :deactivated_at).to eq Time.current
      end
    end
  end

  describe '#reactivate' do
    it 'sets deactivated_at to nil' do
      subject.deactivate
      expect { subject.reactivate }.to change(subject.reload, :deactivated_at).to nil
    end
  end

  describe '#active?' do
    it 'returns true if the record is not deactivated' do
      subject.reactivate
      expect(subject.reload).to be_active
    end

    it 'returns false if the record is deactivated' do
      subject.deactivate
      expect(subject.reload).to_not be_active
    end
  end

  describe '#inactive?' do
    it 'returns false if the record is not deactivated' do
      subject.reactivate
      expect(subject.reload).to_not be_inactive
    end

    it 'returns true if the record is deactivated' do
      subject.deactivate
      expect(subject.reload).to be_inactive
    end
  end
end
