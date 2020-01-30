class CodeMailer < ApplicationMailer
  MEMBER_DELIVERY_TEMPLATE_ID = 'd-bc1519dade554506ad53a63b3b4d3e36'.freeze

  # Bridge Vision Code Delivery
  def registered_email(member)
    dynamic_template_data = {
      codedeliverylink: [mobile_codes_url(id: member.id, token: member.authentication_token)],
      firstname: [member.first_name],
      lastname: [member.last_name],
      purchaseinstructions: [''],
      companyemail: [member.order.email],
      companyname: [member.organization.name],
      specialoffers: [member.format_special_offer_usage_instructions_for_mail]
    }
    mail to: member.email, body: 'email body', template_id: MEMBER_DELIVERY_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html'
  end
end
