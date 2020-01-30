RSpec.describe Orders::GenerateCodesJob do
  let(:order) { create(:order) }
  subject { Orders::GenerateCodesJob.new.perform(order) }
  it do
    expect(Orders::GenerateCodes).to receive(:execute).with(order)
    subject
  end
end
