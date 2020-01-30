FactoryBot.define do
  factory :product_category do
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/nyan-logo.png'), 'image/jpeg') }
    division

    trait :first_data do
      name { 'Safety Eyewear' }
      card_type { :first_data }
    end

    trait :legacy do
      card_type { :legacy }
      name { 'Fashion Eyewear' }
    end

    trait :eml do
      card_type { :eml }
      name { 'Eye Exam' }
    end

    first_data # default
    initialize_with do
      # This makes it so each call to this does _not_ create a new record, unless the 'name' is the different
      ProductCategory.where(name: name).first_or_initialize(attributes)
    end
  end
end
