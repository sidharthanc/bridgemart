module ClosedLoop
  class UnknownField < RuntimeError; end
  class UnknownErrorCode < RuntimeError; end

  USE_MERCHANT_KEY_ENCRYPTION = true
  VERSION_NUMBER = '4'.freeze
  FORMAT_NUMBER = '0'.freeze
  YES = 'Y'.freeze
  NO = 'N'.freeze
  FS = '|1C'.freeze

  TRANSACTION_TYPES = {}.tap do |type|
    type[:timeout_reversal] = { code: '0704' }
    type[:close_account] = { code: '2004', fields: %w[12 13 42 70 EA FA] } # FA is technically not required, but we don't want to leave balances on closed cards
    type[:assign_merchant_working_key] = { code: '2010', fields: %w[12 13 15 42 63 EA F3] }
    type[:freeze_active_card] = { code: '2003', fields: %w[12 13 42 70 EA] } # do we have access?
    type[:unfreeze_active_card] = { code: '2016', fields: %w[12 13 42 70 EA] }
    type[:activate_virtual_card] = { code: '2102', fields: %w[12 13 42 EA F2] }
    type[:activate_physical_card] = { code: '2104', fields: %w[12 13 70 42 EA] }
    type[:reload] = { code: '2300', fields: %w[04 12 13 70 42 EA] }
    type[:balance] = { code: '2400', fields: %w[12 13 70 42 EA] }
    type[:transaction_history] = { code: '2410', fields: %w[12 13 70 42 EA E8] }
    type[:void_reload] = { code: '2801', fields: %w[12 13 70 42 EA] }
    type[:void_activation] = { code: '2802', fields: %w[04 12 13 70 42 EA] }
  end.freeze

  FIELDS = {}.tap do |field|
    field[:transaction_amount] = { code: '04', lambda: ->(amount) { amount.is_a?(Money) ? amount.try(:cents) : amount } } # Amount of the transaction in local currency in smallest unit (cents for USD)
    field[:reference_number] = { code: '08' } # Reference or customer number used for reporting purposes.
    field[:notes] = { code: '09', lambda: ->(note) { note.truncate(20) } } # limit 20
    field[:notes_additional] = { code: '10', lambda: ->(note) { note.truncate(20) } } # limit 20
    field[:merchant_id] = { code: '11', lambda: -> { FirstData::Client.credentials[:mid] } }
    field[:transaction_time] = { code: '12', lambda: -> { DateTime.current.strftime('%H%M%S') } } # HHMMSS
    field[:transaction_date] = { code: '13', lambda: -> { DateTime.current.strftime('%m%d%Y') } } # MMDDCCYY
    field[:transaction_number] = { code: '15' } # Merchant generated transaction number
    field[:extended_account_number] = { code: '34' } # Also known as EAN / PIN
    field[:merchant_and_terminal_id] = { code: '42', lambda: -> { [FirstData::Client.credentials[:mid].to_s, FirstData::Client.credentials[:tid].to_s[7..10]].join } }
    field[:alternate_merchant_number] = { code: '44', lambda: -> { FirstData::Client.credentials[:tid].to_s } } # Alternate merchant ID number. Recommended use of this field is for merchant designated store/location number.
    field[:merchant_key] = { code: '63' }
    field[:embossed_card_number] = { code: '70' }
    field[:history_format] = { code: 'E8', lambda: -> { '84' } }
    field[:expiration_date] = { code: 'A0', lambda: ->(date) { date.strftime('%m%d%Y') } }
    field[:local_currency] = { code: 'C0', lambda: -> { '840' } } # Seems to be ISO 4217
    field[:transaction_count] = { code: 'CF' }
    field[:source_code] = { code: 'EA', lambda: -> { ClosedLoop::USE_MERCHANT_KEY_ENCRYPTION ? '30' : '31' } } # Internet With and without Merchant Key
    field[:promotion_code] = { code: 'F2', lambda: -> { FirstData::Client.credentials[:promo] } }
    field[:merchant_key_id] = { code: 'F3', lambda: -> { FirstData::Client.credentials[:active_merchant_key_id] } } # The Merchant Key ID associated with the Merchant ID  # FIXME we should prolly have a db record?
    field[:original_transaction_request_code] = { code: 'F6' }
    field[:remove_balance] = { code: 'FA', lambda: -> { YES } }
    field[:echo] = { code: '7F' } # Echo Back. Data sent in this field is not checked and is sent back without any changes
  end.freeze

  RESPONSE_FIELDS = FIELDS.each_with_object({}) do |f, memo|
    memo[f.last.fetch(:code)] = f.first
  end.tap do |fields|
    fields['38'] = :authorization_code
    fields['39'] = :response_code
    fields['75'] = :previous_balance
    fields['76'] = :new_balance
    fields['78'] = :lock_amount
    fields['B0'] = :card_class
    fields['CE'] = :first_transaction_number
    fields['EB'] = :count_in_history
    fields['EC'] = :transaction_record_length
    fields['F6'] = :original_transaction_request_code
    fields['D0'] = :transaction_history_detail
  end.freeze

  autoload :Card, 'closed_loop/card'
  autoload :Payload, 'closed_loop/payload'
  autoload :Request, 'closed_loop/request'
  autoload :Response, 'closed_loop/response'

  module Transactions
    autoload :ActivateCard,         'closed_loop/transactions/activate_card'
    autoload :ActivatePhysicalCard, 'closed_loop/transactions/activate_physical_card'
    autoload :AssignMerchantKey,    'closed_loop/transactions/assign_merchant_key'
    autoload :BalanceInquiry,       'closed_loop/transactions/balance_inquiry'
    autoload :CloseCard,            'closed_loop/transactions/close_card'
    autoload :LockCard,             'closed_loop/transactions/lock_card'
    autoload :ReloadCard,           'closed_loop/transactions/reload_card'
    autoload :TransactionHistory,   'closed_loop/transactions/transaction_history'
    autoload :UnlockCard,           'closed_loop/transactions/unlock_card'
    autoload :VoidActivateCard,     'closed_loop/transactions/void_activate_card'
    autoload :VoidReloadCard,       'closed_loop/transactions/void_reload_card'
  end

  def self.using_merchant_key?
    USE_MERCHANT_KEY_ENCRYPTION
  end
end
