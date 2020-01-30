puts '***** Seeding Products *****'
def image(name)
  File.open Rails.root.join('app', 'assets', 'images', name)
end

bridge_vision = Division.find_or_create_by!(name: 'Bridge Vision') do |division|
  division.logo.attach(io: image('bridge-vision-logo.png'), filename: 'bridge-vision-logo.png')
end

bridge_vision.product_categories.find_or_create_by!(name: 'Eye Exam') do |pc|
  pc.background_color = 'lightsalmon'
  pc.fee_type = 'flat_rate'
  pc.flat_fee_cents = 1000
  pc.card_type = 'eml'
  pc.default_redemption_instructions = 'Redeem this product in-store'
  pc.single_use_only = true
  pc.icon.attach(io: image('exam-gray.png'), filename: 'exam-gray.png')
end.tap do |pc| # rubocop:disable Style/MultilineBlockChain
  pc.price_points.find_or_create_by!(item_name: 'routine exam') do |pp|
    pp.verbiage         = 'Each member can afford a routine eye exam.'
    pp.limit            = 65
    pp.limit_type       = 1
    pp.tooltip          = 'Members can afford a routine eye exam'
    pp.upgrade_verbiage = '$35 more to upgrade to a contact lens fitting.'
  end
  pc.price_points.find_or_create_by!(item_name: 'contact lens fitting') do |pp|
    pp.verbiage            = 'Each member can afford a contact lens fitting.'
    pp.limit               = 90
    pp.limit_type          = 3
    pp.tooltip             = 'Members can afford a contact lens fitting'
  end
end

bridge_safety = Division.find_or_create_by!(name: 'Bridge Safety') do |division|
  division.logo.attach(io: image('bridge-safety-logo.png'), filename: 'bridge-safety-logo.png')
end

bridge_safety.product_categories.find_or_create_by!(name: 'Fashion Eyewear') do |pc|
  pc.background_color = 'lightgreen'
  pc.card_type = 'first_data'
  pc.fee_type = 'percentage_rate'
  pc.percentage_fee = 9.0
  pc.default_redemption_instructions = 'Redeem this product in-store'
  pc.icon.attach(io: image('fashion-gray.png'), filename: 'fashion-gray.png')
end.tap do |pc| # rubocop:disable Style/MultilineBlockChain
  pc.price_points.find_or_create_by!(item_name: 'pair of glasses') do |pp|
    pp.verbiage            = 'Each member can afford a pair of glasses or contacts.'
    pp.limit               = 38
    pp.limit_type          = 0
    pp.tooltip             = 'Members can afford a pair of glasses or contacts'
    pp.upgrade_verbiage    = '$82 more to upgrade to a basic pair of glasses or contacts.'
  end
  pc.price_points.find_or_create_by!(item_name: 'basic pair of glasses') do |pp|
    pp.verbiage               = 'Each member can afford a basic pair of glasses or contacts.'
    pp.limit                  = 120
    pp.limit_type             = 1
    pp.tooltip                = 'Members can afford a basic pair of glasses or contacts'
    pp.upgrade_verbiage       = '$60 more to upgrade to a mid-range pair of glasses or contacts.'
  end
  pc.price_points.find_or_create_by!(item_name: 'mid-range pair of glasses') do |pp|
    pp.verbiage               = 'Each member can afford a mid-range pair of glasses or contacts.'
    pp.limit                  = 180
    pp.limit_type             = 2
    pp.tooltip                = 'Members can afford a mid-range pair of glasses or contacts'
    pp.upgrade_verbiage       = '$60 more to upgrade to a high-end pair of glasses or contacts.'
  end
  pc.price_points.find_or_create_by!(item_name: 'high-end pair of glasses') do |pp|
    pp.verbiage               = 'Each member can afford a high-end pair of glasses or contacts.'
    pp.limit                  = 240
    pp.limit_type             = 3
    pp.tooltip                = 'Members can afford a high-end pair of glasses or contacts'
  end
end

bridge_safety.product_categories.find_or_create_by!(name: 'Safety Eyewear') do |pc|
  pc.background_color = 'lightblue'
  pc.fee_type = 'percentage_rate'
  pc.percentage_fee = 9.0
  pc.card_type = 'first_data'
  pc.default_redemption_instructions = 'Redeem this product in-store'
  pc.icon.attach(io: image('safety-gray.png'), filename: 'safety-gray.png')
end.tap do |pc| # rubocop:disable Style/MultilineBlockChain
  pc.price_points.find_or_create_by!(item_name: 'pair of safety eyewear') do |pp|
    pp.verbiage          = 'Each member can afford a pair of safety eyewear.'
    pp.limit             = 38
    pp.limit_type        = 0
    pp.tooltip           = 'Members can afford a pair of safety eyewear'
    pp.upgrade_verbiage  = '$82 more to upgrade to a basic pair of safety eyewear.'
  end
  pc.price_points.find_or_create_by!(item_name: 'basic pair of safety eyewear') do |pp|
    pp.verbiage         = 'Each member can afford a basic pair of safety eyewear.'
    pp.limit            = 120
    pp.limit_type       = 1
    pp.tooltip          = 'Members can afford a basic pair of safety eyewear'
    pp.upgrade_verbiage = '$60 more to upgrade to a good pair of safety eyewear.'
  end
  pc.price_points.find_or_create_by!(item_name: 'good pair of safety eyewear') do |pp|
    pp.verbiage         = 'Each member can afford a good pair of safety eyewear.'
    pp.limit            = 180
    pp.limit_type       = 2
    pp.tooltip          = 'Members can afford a good pair of safety eyewear'
    pp.upgrade_verbiage = '$20 more to upgrade to a pretty good pair of safety eyewear.'
  end
  pc.price_points.find_or_create_by!(item_name: 'pretty good pair of safety eyewear') do |pp|
    pp.verbiage         = 'Each member can afford a pretty good pair of safety eyewear.'
    pp.limit            = 200
    pp.limit_type       = 2
    pp.tooltip          = 'Members can afford a pretty good pair of safety eyewear'
    pp.upgrade_verbiage = '$40 more to upgrade to a great pair of safety eyewear.'
  end
  pc.price_points.find_or_create_by!(item_name: 'great pair of safety eyewear') do |pp|
    pp.verbiage         = 'Each member can afford a high-end pair of safety eyewear.'
    pp.limit            = 240
    pp.limit_type       = 3
    pp.tooltip          = 'Members can afford a high-end pair of safety eyewear'
  end
end

bridge_services = Division.find_or_create_by!(name: 'Bridge Services') do |division|
  division.logo.attach(io: image('bridge-services-logo.png'), filename: 'bridge-services-logo.png')
end
