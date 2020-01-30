RSpec.describe Orders::GenerateCodesForActiveOrdersJob do
  subject { described_class.new.perform }
  let(:active) { create(:order, :paid) }
  let(:active_already_generated) { create(:order, :paid, generated_at: 1.day.ago) }
  let(:inactive) { create(:order, :paid, starts_on: 1.day.from_now) }

  it do
    expect(Orders::GenerateCodesJob).to receive(:perform_later).with(active)
    expect(Orders::GenerateCodesJob).not_to receive(:perform_later).with(inactive)
    expect(Orders::GenerateCodesJob).not_to receive(:perform_later).with(active_already_generated)
    subject
  end
end
