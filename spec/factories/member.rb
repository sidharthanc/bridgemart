FactoryBot.define do
  factory :member do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }

    order
  end
end
