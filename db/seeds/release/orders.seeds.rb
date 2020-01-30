require_relative 'support'
extend Support # rubocop:disable Style/MixinUsage

# FactoryBot.create_list(:organization, scale(2)).each do |organization|
#   puts "Creating Organization: #{organization.name}"
#   organization.orders = FactoryBot.create_list(:order, scale(2), :paid,
#                                                organization: organization,
#                                                plan: FactoryBot.create(:plan,
#                                                                        :with_product)).each do |order, index|
#       puts "Creating Order/s: #{ organization.name } #{ index }"
#       order.members = FactoryBot.create_list(:members, scale(2))
#       GenerateCodesForOrder.generate(order)
#                                                                                             end
# end
