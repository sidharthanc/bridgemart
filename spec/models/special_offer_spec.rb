RSpec.describe SpecialOffer, type: :model do
  it { is_expected.to belong_to(:product_category) }
  it { is_expected.to have_and_belong_to_many(:orders) }
end
