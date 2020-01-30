FactoryBot.define do
  factory :organization, aliases: [:billable] do
    name { Faker::Company.name }
    industry { SignUp::INDUSTRIES.sample } # TODO: move to Organization
    association :primary_user, factory: :user

    trait :with_credit do
      after :create do |org|
        create_list :credit, 1, organization: org, amount: Money.new(100_00)
      end
    end
  end
end
