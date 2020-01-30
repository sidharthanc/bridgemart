FactoryBot.define do
  factory :billing_contact do
    email { Faker::Internet.email }
    for_organization

    trait :for_organization do
      association :billable, factory: :organization
    end
  end
end
