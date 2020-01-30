FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    password { Faker::Internet.password(10, 20) }

    factory :admin do
      after(:create) do |user, _evaluator|
        create(:permission_group, users: [user], admin: true)
      end
    end

    trait :deleted do
      deleted_at { 2.days.ago }
    end

    trait :with_organization do
      after(:create) do |user, _evaluator|
        create(:organization, primary_user: user)
      end
    end
  end
end
