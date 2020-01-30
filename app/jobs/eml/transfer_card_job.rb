module EML
  class TransferCardJob < ::ApplicationJob
    include EML::Client
    include DeliverCodes

    def perform(code, note)
      response = post transfer_url(code), params: { note: note, client_tracking_id: code.uuid, tocardtype: 2, location: { name: activating_merchant_group_name_for(code) } }

      Code.create!(
        member: code.member,
        status: :registered,
        limit: code.limit,
        balance: response['actual_balance'].to_money,
        external_id: response['id'],
        plan_product_category: code.plan_product_category
      )

      deliver_codes_to code.member
    end

    private
      def transfer_url(code)
        "cards/#{code.card_number}/transfer"
      end

      def card_url(code)
        "cards/#{code.card_number}"
      end

      def activating_merchant_group_name_for(code)
        response = get card_url(code), params: { fields: 'activating_merchant_group_name' }
        response['activating_merchant_group_name']
      end
  end
end
