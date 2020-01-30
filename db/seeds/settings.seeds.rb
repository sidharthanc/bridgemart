puts '***** Seeding Settings *****'
Setting.find_or_create_by!(key: :external_locator_url) do |setting|
  setting.value = 'http://bridgedrnetwork.com/locate'
end
