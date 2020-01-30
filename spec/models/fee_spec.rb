RSpec.describe Fee, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:rate_cents) }
  end

  it { is_expected.to be_auditable }
end
