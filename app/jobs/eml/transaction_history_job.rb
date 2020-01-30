module EML
  class TransactionHistoryJob < ::ApplicationJob
    include EML::Client

    rescue_from(StandardError) do |exception|
      Rails.logger.error "Error in [#{self.class.name}] -- Exception: #{exception}"
    end

    def perform(code)
      return unless code.active?

      get "cards/#{code.card_number}/transactions", params: { fields: 'all', client_tracking_id: code.uuid } do |response|
        response['transactions'].each do |transaction|
          CodeActions::ImportTransaction.new(
            code: code,
            transaction: EML::Transaction.parse(transaction)
          ).import
        end
      end
    end
  end
end
