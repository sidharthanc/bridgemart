class PaymentMethod < ApplicationRecord
  acts_as_paranoid

  include HasAddress
  include Billable

  PAYMENT_TYPE_ACCRUED_CREDIT = 'accrued_credits'.freeze

  attribute :credit_card_cvv
  attribute :ach_routing_number

  belongs_to :organization

  scope :chronological, -> { order(:created_at) }

  def payment_type
    return :credit if credit_card_token.present?
    return :ach if ach_account_token.present?
  end

  def credit_card_number
    obfuscated(credit_card_token)
  end

  def payment_card_number
    payment_type == :ach ? "ACH #{ach_account_number}" : "CREDIT #{credit_card_number}"
  end

  def ach_account_number
    obfuscated(ach_account_token)
  end

  concerning :ViewHelpers do
    def credit_card_expiration_date_formatted
      credit_card_expiration_date[0, 2] + '/' + credit_card_expiration_date[-2, 4]
    end
  end

  private
    def obfuscated(v)
      return '' unless v.present?

      v.last(4).rjust(v.length, '*')
    end
end
