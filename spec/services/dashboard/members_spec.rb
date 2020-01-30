describe Dashboard::Members do
  subject { described_class.new organization: organization }
  let(:organization) { organizations(:metova) }
  let(:order) { orders(:metova) }

  describe '#count' do
    it 'returns the number of members in the organization attached via order' do
      pending 'now memoized for performance'
      expect do
        usages(:matt).destroy
        members(:logan).destroy
      end.to change(subject, :count).by -1
    end
  end

  describe '#show?' do
    context 'with a persisted plan' do
      it 'should show' do
        expect(subject.show?).to be true
      end
    end

    context 'with an unpersisted plan' do
      let(:plan) { Plan.new }

      it 'should not show' do
        pending 'Dont think this is needed anymore?'
        expect(subject.show?).to be false
      end
    end
  end
end
