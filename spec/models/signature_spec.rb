RSpec.describe Signature, type: :model do
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to belong_to(:commercial_agreement) }
end
