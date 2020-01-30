class Cards::UpdateVirtualCardProviderJob < ApplicationJob
  def perform
    Code.where(virtual_card_provider: nil).find_each do |code|
      code.update(virtual_card_provider: code.product_category.card_type.to_sym)
    end
  end
end
