FactoryBot.define do
  factory :order do
    plan
    starts_on { DateTime.current }
    ends_on { DateTime.current + 1.year }

    factory :paid_order_with_codes do
      paid

      transient do
        codes_count { 3 }
        after(:create) do |order, evaluator|
          create_list(:activated_code, evaluator.codes_count, order: order)
        end
      end
    end

    trait :active do
      starts_on { 1.day.ago }
    end

    trait :processed do
      processed_at { DateTime.current }
    end

    trait :paid do
      processed
      paid_at { DateTime.current }
      payment_method
    end

    trait :legacy do
      legacy_identifier { Faker::Number.unique.number(10) }
    end
  end
end
