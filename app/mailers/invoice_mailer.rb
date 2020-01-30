class InvoiceMailer < ApplicationMailer
  CREDENTIALS_EMAIL_TEMPLATE_ID = 'd-f6e04acb0e0d4779b5540aca8b1a3e4c'.freeze

  def enrollment_invoice_email(order)
    return unless order.invoice_sent_at.blank?

    dynamic_template_data = {
      organizationname: [order.organization.name],
      plantype: ['Pre-Pay'],
      invoicenumber: [order.id],
      startdate: [I18n.l(order.starts_on, format: :Mddyyyy)],
      ponumber: [order.po_number]
    }
    order.touch(:invoice_sent_at) if mail(to: order.email, body: 'email body', template_id: CREDENTIALS_EMAIL_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html')
  end
end
