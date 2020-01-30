describe MemberSession do
  subject { described_class.new({}) }

  describe '#store' do
    let(:member) do
      OpenStruct.new(id: 1, first_name: 'Test', middle_name: 'T', last_name: 'Testerson')
    end

    it 'adds a member' do
      expect { subject.store member }.to change(subject, :count).by 1
      expect(subject.first.first_name).to eq 'Test'
      expect(subject.first.middle_name).to eq 'T'
      expect(subject.first.last_name).to eq 'Testerson'
    end

    it 'updates a member' do
      subject.store member
      member['first_name'] = 'Updated'
      expect { subject.store member }.to_not change(subject, :count)
      expect(subject.first.first_name).to eq 'Updated'
    end
  end

  describe 'Member' do
    describe 'to_s' do
      it 'returns the name in last, first format' do
        member = MemberSession::Member.new 'first_name' => 'Test', 'last_name' => 'Testerson'
        expect(member.to_s).to eq 'Testerson, Test'
      end

      it 'includes the middle initial if present' do
        member = MemberSession::Member.new 'first_name' => 'Test', 'middle_name' => 'Test', 'last_name' => 'Testerson'
        expect(member.to_s).to eq 'Testerson, Test T.'
      end
    end
  end
end
