module Backfill
  class CodeExpiresStartsOn < ApplicationJob
    def perform
      Code.includes(:order).where(starts_on: nil, expires_on: nil).find_each(batch_size: 50) do |code|
        code.update(starts_on: code.order.starts_on, expires_on: code.order.ends_on)
      end
    end
  end
end
