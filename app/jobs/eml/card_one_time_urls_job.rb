require 'base64'

module EML
  class CardOneTimeUrlsJob < ::ApplicationJob
    include EML::Client
    include ActionView::Helpers::AssetUrlHelper

    def perform(code)
      response = get card_url(code), params: { fields: 'barcode_image,card_image', client_tracking_id: code.uuid }
      code.update(
        barcode_url: apply_barcode_params(response['barcode_image']),
        card_image_url: response['card_image']
      )
    end

    private
      def card_url(code)
        "cards/#{code.card_number}"
      end

      def apply_barcode_params(url)
        "#{url}?barcodeContentType=NONE"
      end
  end
end
