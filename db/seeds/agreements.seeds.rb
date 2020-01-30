puts '***** Seeding Products *****'
CommercialAgreement.first_or_create! do |agreement|
  pdf_name = '536663049_v_6_CommercialAccountAgreementweSign.pdf'
  attachment_path = Rails.root.join('app', 'assets', 'pdfs', pdf_name)
  agreement.pdf.attach(io: File.open(attachment_path), filename: pdf_name)
end
