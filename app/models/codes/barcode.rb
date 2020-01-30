require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/svg_outputter'
require 'active_storage_base64'

module Codes
  module Barcode
    BARCODE_PREFIX = '87458604272000'.freeze # Magic Value from Walmart

    extend ActiveSupport::Concern
    include ::ActiveStorageSupport::SupportForBase64

    included do
      has_one_base64_attached :barcode
    end

    def update_code_with_remote_source
      if !barcode.attached?
        if product_category.eml?
          EML::CardOneTimeUrlsJob.perform_now(self)

          card_image_data = retrieve_card_image_from_eml
          self.card_number ||= card_image_data.fetch('card_number')
          self.pin = card_image_data.fetch('cvv')
          self.barcode = { data: retrieve_barcode_image_from_eml }
        else
          self.barcode = { data: "data:image/svg+xml;utf8,#{generate_barcode(card_number, true).gsub(/\n/, '')}" }
        end
      end
      save if valid?
    end

    protected
      def retrieve_card_image_from_eml
        return unless card_image_url.present?

        src = Nokogiri::HTML(open(card_image_url)).css('#cardData')
        {}.tap do |data|
          data['card_number'] = src.css('.cardNumberSegment').map(&:content).join
          data['cvv'] = src.css('#cvv').first.content
          data['security_code'] = src.css('#securityCode').first.content
          data['expiration_date'] = src.css('#expirationDate').first.content
        end
      end

      def retrieve_barcode_image_from_eml
        return unless barcode_url.present?

        Nokogiri::HTML(open(barcode_url)).css('img').first['src']
      end

      def retrieve_barcode_image_from_eml_show_view
        EML::CardOneTimeUrlsJob.perform_now(self)
        Nokogiri::HTML(open(barcode_url)).css('img').first['src']
      end

    private
      def generate_barcode(value, prefix = false)
        value = BARCODE_PREFIX + value if prefix

        barby = Barby::Code128.new(value, "A")
        barcode_output = Barby::SvgOutputter.new(barby)
        barcode_output.height = 60
        barcode_output.margin = 0
        barcode_output.xdim = 0.80 # using odd xdims with SVG give degrade quality svgs
        barcode_output.to_svg
      end
      def barcode_prefix_card_comb_value(value)
       return BARCODE_PREFIX + value
      end
  end
end
