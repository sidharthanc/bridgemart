module EML
  class BatchExpireCardJob < ::ApplicationJob
    def perform
      Code.at_or_past_expiration.with_card_type(:eml).find_each do |code|
        EML::ExpireCardJob.perform_later code
      end
    end
  end
end
