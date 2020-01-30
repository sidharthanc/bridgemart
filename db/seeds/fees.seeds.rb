puts '***** Seeding Products *****'
Fee.find_or_create_by!(description: 'First Month Program Management Fee') do |fee|
  fee.rate_cents = 125
end

Fee.find_or_create_by!(description: 'Exam Network Access') do |fee|
  fee.rate_cents = 1000
end
