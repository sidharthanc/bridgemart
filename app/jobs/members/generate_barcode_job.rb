require 'barcode_service'

module Members
  class GenerateBarcodeJob < ApplicationJob
    queue_as :low

    def perform(member)
      return unless member.external_member_id

      temp_file = BarcodeService.new(style: :matrix).generate(member.external_member_id)
      member.barcode_image.attach(io: temp_file.open, filename: "#{member.external_member_id}.jpg", content_type: "image/jpeg")
      member.save
    end
  end
end
