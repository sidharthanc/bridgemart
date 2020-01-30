FactoryBot.define do
  factory :payment_method do
    organization
    address
    billing_contact

    factory :ach do
      ach_account_token { Faker::Number.number(10) }
    end

    factory :credit_card do
      credit_card_token { Faker::Number.number(10) }
    end
  end
end
