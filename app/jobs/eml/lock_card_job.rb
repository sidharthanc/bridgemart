module EML
  class LockCardJob < ::ApplicationJob
    include EML::Client

    NOTE = 'Temporary Lock'.freeze

    REASON_MAP = {
      damaged: 'Damaged',
      lost: 'Lost',
      office_error: 'OfficeError',
      expired: 'PastAccountExpirationDate',
      stolen: 'Stolen',
      unclaimed: 'UnclaimedProperty',
      misc: 'Miscellaneous'
    }.freeze

    def perform(code, reason)
      post lock_card_url(code), params: { note: NOTE, reason: api_reason(reason), client_tracking_id: code.uuid }
      card_should_be_closed?(reason) ? code.closed : code.locked
    end

    private
      def lock_card_url(code)
        "cards/#{code.card_number}/locks"
      end

      def card_should_be_closed?(reason)
        reason.to_s.in? %w[lost stolen]
      end

      def api_reason(reason)
        REASON_MAP.fetch reason.to_sym, REASON_MAP[:misc]
      end
  end
end
