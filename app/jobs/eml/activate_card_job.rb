module EML
  class ActivateCardJob < ::ApplicationJob
    # These are likely happening b/c the hooks are right, it should enqueu on the job on the create :on_commit
    retry_on ActiveJob::DeserializationError
    retry_on ActiveRecord::RecordNotFound

    include EML::Client

    def perform(code)
      code.update status: :activating
      card = parse post('cards/new/activations', params: { amount: code.limit.to_d, client_tracking_id: code.uuid })
      code.activated card
    end

    private
      def parse(response)
        EML::Card.new(
          id: response['id'],
          balance: response['available_balance'],
          pan:  response['pan']
        )
      end
  end
end
