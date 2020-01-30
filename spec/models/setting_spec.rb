RSpec.describe Setting, type: :model do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:value) }

  describe 'uniqueness' do
    let!(:subject) { settings(:external_locator_url) }
    it { is_expected.to validate_uniqueness_of(:key) }
  end
end
