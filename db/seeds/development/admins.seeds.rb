after :roles do
  puts '***** Seeding Admin Users *****'
  FactoryBot.create(:admin,
                    email: 'admin@bridge-vision.com',
                    password: 'password',
                    first_name: 'Bridge',
                    last_name: 'Admin')
  puts 'Admin:  admin@bridge-vision.com / password'
end
