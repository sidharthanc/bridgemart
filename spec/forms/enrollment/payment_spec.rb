RSpec.describe Payment, type: :model do
  let(:valid_params) do
    {
      billing_id: '8675309eien',
      credit_card_token: '4111111111111111',
      credit_card_expiration_date: '10/25',
      first_name: 'first_name',
      last_name: 'last_name',
      email: 'email@example.com',
      street1: '123 billing dr.',
      city: 'Billing City',
      state: 'DE',
      zip: 12_343
    }
  end

  let(:invalid_params) do
    {
      first_name: 'first_name',
      last_name: 'last_name',
      email: 'email@example.com',
      street1: '123 billing dr.',
      state: 'Delaware',
      zip: 12_343
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:street1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip) }
  end

  describe '#initialize' do
    it 'assigns the attributes' do
      payment = Payment.new(valid_params)
      expect(payment).to have_attributes(
        credit_card_token: '4111111111111111',
        credit_card_expiration_date: '10/25',
        first_name: 'first_name',
        last_name: 'last_name',
        email: 'email@example.com',
        street1: '123 billing dr.',
        city: 'Billing City',
        state: 'DE',
        zip: 12_343
      )
    end
  end

  describe '#save' do
    it 'returns true if valid' do
      payment = Payment.new(valid_params)
      payment.order = orders(:metova)
      expect(payment.save).to eq true
    end

    it 'returns false if invalid' do
      payment = Payment.new(invalid_params)
      payment.order = orders(:metova)
      expect(payment.save).to eq false
    end
  end
end
