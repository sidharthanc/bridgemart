class Orders::DeletePendingOrdersJob < ApplicationJob
  queue_as :default

  def perform
    Order.where(Order.arel_table[:created_at].lt(30.days.ago)).where(processed_at: nil, is_cancelled: [false, nil], paid: [false, nil]).destroy_all
  end
end
