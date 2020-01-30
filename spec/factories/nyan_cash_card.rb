FactoryBot.define do
  factory :nyan_cash_card, class: 'NyanCash::Card' do
    initial_balance { Faker::Number.number(4) }
  end
end
