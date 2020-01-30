module Cards
  class BatchRecalculateStatus < ::ApplicationJob
    def perform
      Code.find_each(batch_size: 100) do |code|
        code.update(status: code.detect_status_based_on_balance)
      end
    end
  end
end
