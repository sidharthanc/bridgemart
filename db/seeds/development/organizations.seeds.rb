puts '***** Seeding Oraganizations *****'
Organization.find_or_create_by!(name: 'Spacely Space Sprockets, Inc.') do |org|
  org.industry = 'Technology'
  org.primary_user = User.find_or_create_by!(email: 'cosmo@spacelyspacesprockets.com') do |u|
    u.first_name = 'Cosmo'
    u.last_name = 'Spacely'
    u.password, u.password_confirmation = 'sprockets'
  end
end
