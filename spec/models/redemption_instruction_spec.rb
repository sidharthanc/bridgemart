RSpec.describe RedemptionInstruction, type: :model do
  let(:redemption_instruction) { redemption_instructions(:fashion_instruction) }
  let(:inactive_redemption_instruction) { redemption_instructions(:exam) }
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to belong_to(:product_category) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe 'deleting redemption instruction' do
    it 'should delete inactive redemption instruction' do
      expect { inactive_redemption_instruction.destroy }.to change(RedemptionInstruction, :count).by(-1)
    end

    it 'should not delete active redemption instruction' do
      redemption_instruction.update(active: true)
      expect { redemption_instruction.destroy }.to change(RedemptionInstruction, :count).by(0)
    end
  end

  describe "updating the redemption instruction" do
    it 'should have atleast one active instruction' do
      redemption_instruction.update(title: 'Last Active')
      expect(redemption_instruction.active_instructions.size).to be >= 1
    end
  end
end
