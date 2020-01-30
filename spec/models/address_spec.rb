RSpec.describe Address, type: :model do
  describe '#street1' do
    it { is_expected.to validate_presence_of(:street1) }
    it { is_expected.to validate_length_of(:street1).is_at_most(255) }
  end

  describe '#city' do
    it { is_expected.to validate_presence_of(:city) }
  end

  describe '#state' do
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to allow_value(Faker::Address.state_abbr).for(:state) }
    it { is_expected.to_not allow_value("This is not a state.").for(:state) }
  end

  describe '#zip' do
    it { is_expected.to validate_presence_of(:zip) }
    it { is_expected.to allow_value(Faker::Address.zip_code).for(:zip) }
    it { is_expected.to_not allow_value("This is not a zip code.").for(:zip) }
  end
end
