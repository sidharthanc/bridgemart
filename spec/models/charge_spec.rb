RSpec.describe Charge, type: :model do
  describe '#price' do
    let(:fee) { fees(:management_fee) }
    let(:charge) { Charge.new(fee, 100, :fee) }

    it 'returns rate times number of members of a plan' do
      expect(charge.price.format).to eq '$125.00'
    end
  end
end
