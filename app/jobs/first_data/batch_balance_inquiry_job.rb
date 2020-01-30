module FirstData
  class BatchBalanceInquiryJob < ::ApplicationJob
    queue_as :low

    def perform(code_ids = nil)
      codes = if code_ids
                Code.where(id: code_ids)
              else
                Code.unexpired.active.with_card_type(:first_data).where.not(external_id: nil)
              end

      codes.find_each do |code|
        ::FirstData::BalanceInquiryJob.perform_later code
      end
    end
  end
end
