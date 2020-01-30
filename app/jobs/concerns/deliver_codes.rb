module DeliverCodes
  extend ActiveSupport::Concern

  def deliver_codes_to(member)
    return unless member.codes.where(delivered: false).exists?

    CodeMailer.registered_email(member).deliver_later
    member.codes.each(&:delivered!)
  end
end
