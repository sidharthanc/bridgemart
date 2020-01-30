FactoryBot.define do
  factory :usage do
    code
    amount { Money.new(Faker::Number.number(3)) }
  end
end
