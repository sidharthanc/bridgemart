RSpec.describe ProductCategory, type: :model do
  it { is_expected.to have_many(:plans) }
  it { is_expected.to have_many(:plan_product_categories) }
  it { is_expected.to have_many(:price_points) }
  it { is_expected.to belong_to(:division) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:card_type) }
  it { is_expected.to have_many(:redemption_instructions) }
  it { is_expected.to be_auditable }

  describe '#card_name' do
    let(:product_category) { ProductCategory.new(division: divisions(:bridge_safety), name: 'foobar') }

    it 'should add Code to the product_category name' do
      expect(product_category.card_name).to eq t('product_categories.card_name', name: product_category.name)
    end
  end
end
