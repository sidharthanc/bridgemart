module EML
  class BatchTransactionHistoryJob < ::ApplicationJob
    queue_as :scheduled

    include EML::Client

    def perform
      Code.unexpired.active.with_card_type(:eml).where.not(external_id: nil).find_each do |code|
        EML::TransactionHistoryJob.perform_later code
      end
    end
  end
end
