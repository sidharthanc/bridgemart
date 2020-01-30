RSpec.describe PlanProductCategory, type: :model do
  it { is_expected.to belong_to(:plan) }
  it { is_expected.to belong_to(:product_category) }
  it { is_expected.to have_many(:redemption_instructions) }

  # Commented out. Does not match platform specs
  xdescribe "#budget_cents" do
    it "Invalid budget amount when budget amount is less than minimum limit value of price points" do
      category = plan_product_categories(:exam)
      category.budget = 10.to_money
      expect(category).to be_invalid
      expect(category.errors.messages[:budget_cents].first).to eq "invalid budget amount!"
    end
    it "Invalid budget amount when budget amount is greater than maximum limit value of price points" do
      category = plan_product_categories(:exam)
      category.budget = 100.to_money
      expect(category).to be_invalid
      expect(category.errors.messages[:budget_cents].first).to eq "invalid budget amount!"
    end
  end
end
