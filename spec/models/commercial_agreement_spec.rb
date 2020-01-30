RSpec.describe CommercialAgreement, type: :model do
  it { is_expected.to have_many(:signatures) }
  it { is_expected.to have_many(:organizations) }
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to be_auditable }

  it 'saves the old filename in the audit trail' do
    commercial_agreement = CommercialAgreement.new
    commercial_agreement.pdf.attach to_file('test.pdf')
    commercial_agreement.save!

    commercial_agreement.pdf.attach to_file('test2.pdf')
    commercial_agreement.save!
    expect(commercial_agreement.audits.last.comment).to match /test2.pdf$/
  end

  describe "when assign organization to the document" do
    it "saves the document successfully" do
      commercial_agreement = CommercialAgreement.new
      commercial_agreement.pdf.attach to_file('test.pdf')
      commercial_agreement.organization = Organization.last
      expect(commercial_agreement).to be_valid
      expect(commercial_agreement.save).to be true
    end
  end

  it 'should return only nil organization_id in latest scope' do
    commercial_agreements = CommercialAgreement.with_organization.last
    expect(commercial_agreements.organization_id).to eq nil
  end

  def to_file(name)
    { io: File.open(Rails.root.join('spec/fixtures/files/', name)), filename: name }
  end
end
