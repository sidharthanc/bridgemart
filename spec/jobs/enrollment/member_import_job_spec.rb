RSpec.describe Enrollment::MemberImportJob do
  let!(:member_import) { MemberImport.create file: csv, order: orders(:metova) }

  context 'success' do
    let(:csv) { fixture_file_upload('files/members.csv') }

    it 'creates a member for each row of the CSV' do
      expect do
        subject.perform member_import
      end.to change(Member, :count).by 20
    end

    it 'saves the appropriate data on the member' do
      subject.perform member_import
      Member.last.tap do |member|
        expect(member.first_name).to eq 'Test'
        expect(member.middle_name).to eq 'T'
        expect(member.last_name).to eq 'Testerson'
        expect(member.email).to eq 'test@metova.com'
        expect(member.order).to eq orders(:metova)
      end
    end

    it 'saves the address information and attaches it to the member' do
      subject.perform member_import
      Member.last.address.tap do |address|
        expect(address.street1).to eq '320 Aspen Grove Drive'
        expect(address.city).to eq 'Franklin'
        expect(address.state).to eq 'TN'
        expect(address.zip).to eq '37067'
      end
    end
  end

  context 'failure' do
    let(:csv) { fixture_file_upload('files/members.invalid.csv') }
    let(:problems) { member_import.reload.problems }

    it 'does not save any of the members' do
      expect do
        subject.perform member_import
      end.to_not change(Member, :count)
    end

    it 'reports problems with the upload' do
      subject.perform member_import
      expect(problems[0]['last_name']).to eq [{ 'error' => 'blank' }]
      expect(problems[0]['errors']).to eq ["Last name can't be blank"]
      expect(problems[1]['email']).to eq [{ 'error' => 'invalid', 'value' => 'not-valid-email!' }]
      expect(problems[1]['errors']).to eq ['Email is invalid']
      expect(problems[2]['errors']).to eq ["First name can't be blank", "Last name can't be blank"]
    end

    it 'includes the row number in the problems field' do
      subject.perform member_import
      expect(problems[0]['index']).to eq 1
      expect(problems[1]['index']).to eq 3
    end
  end
end
