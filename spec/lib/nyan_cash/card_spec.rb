describe NyanCash::Card, type: :model do
  it { is_expected.to have_db_column(:card_number) }
  it { is_expected.to have_db_column(:pin) }
  it { is_expected.to have_db_column(:initial_balance) }
  it { is_expected.to have_db_column(:current_balance) }
  it { is_expected.to have_db_column(:expires_at) }
  it { is_expected.to have_db_column(:locked_at) }
  it { is_expected.to have_db_column(:closed_at) }

  describe 'default values' do
    subject(:card) { described_class.create(initial_balance: 500) }
    it 'current set to initial balance' do
      expect(card.initial_balance).to eq 500
      expect(card.current_balance).to eq 500
    end
    it 'expiry is 1 year out' do
      expect(card.expires_at).to be_present
    end
    it 'card number is populated' do
      expect(card.card_number).to be_present
    end
    it 'pin is populated' do
      expect(card.pin).to be_present
    end
  end

  describe 'validations' do
    it { is_expected.to allow_value(5_00, 42_98, 1_000_00).for(:initial_balance) }
    it { is_expected.to_not allow_value(4_99, 1_001_00).for(:initial_balance) }

    it { is_expected.to validate_presence_of(:card_number) }

    it { is_expected.to validate_presence_of(:pin) }

    it { is_expected.to validate_presence_of(:initial_balance) }
    it { is_expected.to validate_presence_of(:current_balance) }

    context 'card_number in use' do
      let!(:existing) { NyanCash::Card.create(initial_balance: 5_00) }
      it do
        new_card = NyanCash::Card.new(initial_balance: 5_00, card_number: existing.card_number)
        expect { new_card.valid? }.to change(new_card, :card_number)
      end
    end
  end
end
