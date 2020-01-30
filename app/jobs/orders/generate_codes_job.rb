module Orders
  class GenerateCodesJob < ApplicationJob
    def perform(order)
      Orders::GenerateCodes.execute(order)
    end
  end
end
