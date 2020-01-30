FactoryBot.define do
  factory :plan do
    organization
    with_product

    trait :with_product do
      after(:create) do |plan|
        create(:plan_product_category, plan: plan)
      end
    end
  end
end
