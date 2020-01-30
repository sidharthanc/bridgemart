require 'net/http'
require 'stringio'

module Orders
  class GenerateCodePdfForOrderJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(order)
      pdf = CombinePDF.new
      ActiveStorage::Current.host ||= Rails.application.routes.default_url_options[:host]
      order.codes.each do |code|
        next unless code.pdf.attached?

        pdf << CombinePDF.parse(Net::HTTP.get(URI.parse(code.pdf.blob.service_url)))
      end
      pdf.number_pages(number_format: '%05d', location: :bottom)
      order.pdf.attach(io: StringIO.new(pdf.to_pdf), filename: "order-#{order.id}.pdf", content_type: "application/pdf")
    end
  end
end
