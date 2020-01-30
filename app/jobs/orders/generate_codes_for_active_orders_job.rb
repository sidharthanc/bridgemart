module Orders
  class GenerateCodesForActiveOrdersJob < ApplicationJob
    queue_as :scheduled

    def perform
      Order.active.where(generated_at: nil).find_each do |order|
        Orders::GenerateCodesJob.perform_later(order)
      end
    end
  end
end
