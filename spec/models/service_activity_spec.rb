RSpec.describe ServiceActivity, type: :model do
  class DummyTestService
    def self.flumox
      42
    end
  end

  let(:exception) { RuntimeError.new("Something Bad Happend Dave!") }
  let(:details) { { val1: "value1", val2: "value2" } }

  it { should allow_value(subject.send(:exception_to_hash, exception)).for(:exception) }
  it { should allow_value(details).for(:metadata) }

  describe '.record' do
    subject do
      sa = nil
      described_class.record(DummyTestService, :flumox) do |activity|
        sa = activity
        DummyTestService.flumox
      end
      sa
    end

    it 'creates a record' do
      expect { subject }.to change(described_class, :count).by(1)
    end

    it 'updates with an "OK" unless an error occurs' do
      expect(subject.message).to eq 'OK'
    end

    it 'allows overriding message' do
      sa = nil
      described_class.record("DummyTestService", :flumox) do |activity|
        DummyTestService.flumox
        activity.success "Great Success!"
        sa = activity
      end
      expect(sa.reload.message).to eq "Great Success!"
    end

    it 'returns inner value' do
      value = described_class.record(DummyTestService, :flumox) do |_activity|
        DummyTestService.flumox
      end

      expect(value).to eq 42
    end

    context 'when an exception occurs' do
      before { expect(DummyTestService).to receive(:flumox).and_raise(RuntimeError, "Flumoxing failed") }
      it 'creates a service activity record' do
        expect { subject }.to raise_error(RuntimeError).and change(ServiceActivity, :count).by(1)
      end

      it 'updates with exception' do
        sa = nil
        begin
          described_class.record("DummyTestService", :flumox) do |activity|
            sa = activity
            DummyTestService.flumox
          end
        rescue RuntimeError => e
          e
        end
        sa.reload

        expect(sa.message).not_to eq 'OK'
        expect(sa.exception).to be_present
        expect(sa.exception[:message]).to eq "Flumoxing failed"
      end
    end
  end

  describe 'scopes' do
    subject { described_class }
    it 'successful lists only sucessful' do
      expect(subject.successful).to all(satisfy { |sa| sa.successful_at.present? })
    end
    it 'failures lists only failures' do
      expect(subject.failures).to all(satisfy { |sa| sa.failure_at.present? })
    end
  end

  describe '#success' do
    subject { described_class.create(service: "SomeService", action: "AnAction") }
    it { expect { subject.success }.to change { subject.successful_at } }
    it { expect { subject.success }.to change { subject.message } }
  end

  describe '#failure' do
    subject { described_class.create(service: "SomeService", action: "AnAction") }
    it { expect { subject.failure("Something Bad") }.to change { subject.failure_at } }
    it { expect { subject.failure("Something Bad") }.to change { subject.message }.to("Something Bad") }
    it { expect { subject.failure(exception) }.to change { subject.failure_at } }
    it { expect { subject.failure(exception) }.to change { subject.exception } }
  end
end
