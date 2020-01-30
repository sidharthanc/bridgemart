class MemberMailer < ApplicationMailer
  DEACTIVATE_MEMBER_EMAIL_TEMPLATE_ID = 'd-e985e992244848149a6e0ae6baff1a6b'.freeze
  DEACTIVATE_CODE_EMAIL_TEMPLATE_ID = 'd-6dbaa61d678d4ab8879c1acaa45dcdce'.freeze

  def deactivate_member(member)
    dynamic_template_data = {
      'member-name': ["#{member.first_name} #{member.last_name}"],
      'member-id': [member.id.to_s],
      'member-email': [member.email.to_s],
      'user-email': [member.organization.primary_user.email.to_s],
      'organization-name': [member.organization.name.to_s]
    }
    mail to: member.email, body: 'email body', template_id: DEACTIVATE_MEMBER_EMAIL_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html'
  end

  def deactivate_code(code)
    return unless code.deactivated_email_sent_at.blank?

    subject = "Your code ending in #{code.card_number.last(4)} has been deactivated."
    message = "Hello, #{code.member&.first_name}. We're letting you know your code ending in #{code.card_number.last(4)} has been deactivated. If you have any questions, please reach out to your organization. Thanks for being a member at Bridge. We hope to see you again soon."
    dynamic_template_data = {
      'subject': subject,
      'message': message,
      'button_text': false
    }
    mail to: code.member.email, subject: subject, body: 'email body', template_id: DEACTIVATE_CODE_EMAIL_TEMPLATE_ID, dynamic_template_data: dynamic_template_data, content_type: 'text/html'
  end
end
