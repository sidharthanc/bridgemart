RSpec.describe Division, type: :model do
  it { is_expected.to have_many(:product_categories) }
  it { is_expected.to validate_presence_of(:name) }
end
