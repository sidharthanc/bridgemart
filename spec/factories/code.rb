FactoryBot.define do
  factory :code do
    limit { Money.new(Faker::Number.number(3)) }
    member
    order
    plan_product_category

    trait :legacy do
      legacy_identifier { Faker::Number.unique.number(10) }
    end

    trait :activated do
      card_number { Faker::Number.unique.number(16) }
      pin { Faker::Number.unique.number(4) }
      balance_cents { limit_cents }
      status { 'activated' }
    end

    factory :activated_code do
      external_id { Faker::Number.unique.number(16) }
      status { 'activated' }
    end
  end
end
