RSpec.describe BillingContact, type: :model do
  it { is_expected.to belong_to(:billable) }
  it { is_expected.to be_auditable }
end
