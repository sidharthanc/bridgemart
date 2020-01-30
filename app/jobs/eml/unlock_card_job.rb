module EML
  class UnlockCardJob < ::ApplicationJob
    include EML::Client

    NOTE = 'Unlock the Card'.freeze

    def perform(code)
      post unlock_card_url(code), params: { note: NOTE, client_tracking_id: code.uuid }
      code.registered
    end

    private
      def unlock_card_url(code)
        "cards/#{code.card_number}/unlocks"
      end
  end
end
