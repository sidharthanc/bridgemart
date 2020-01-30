FactoryBot.define do
  factory :plan_product_category do
    plan
    product_category
    budget { Money.new(rand(10) * 10_00) }
  end
end
