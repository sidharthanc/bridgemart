module Codes
  class GenerateCodePdfJob < ApplicationJob
    def perform(code, options = {})
      code.pdf.purge if code.pdf.attached?
      code.update_code_with_remote_source
      code.reload
      code_pdf_html = renderer.render(
        template: 'mobile/codes/show',
        layout: 'layouts/default.pdf',
        assigns: { code: code, member: code.member, options: options }
      )
      doc_pdf = WickedPdf.new.pdf_from_string(code_pdf_html, page_size: 'Letter')
      code.pdf.attach(io: StringIO.new(doc_pdf), filename: "code-#{code.card_number}.pdf", content_type: "application/pdf")
      code.generate_order_pdf_if_all_codes_activated self
    end

    protected
      def renderer
        ApplicationController.renderer.new(
          http_host: Rails.application.routes.default_url_options[:host],
          https: Rails.env.production?
        )
      end
  end
end
