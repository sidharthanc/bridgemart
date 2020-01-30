class PaymentService
  PAYMENT_TRIGGER_ECOMMERCE = 'E'.freeze
  PAYMENT_TRIGGER_RECURRING = 'R'.freeze

  def self.credentials
    Rails.application.credentials.dig(Rails.env.to_sym, :cardconnect)
  end

  # @param [Object] payment_method payment_method to be processed
  # @param [Decimal] amount amount to charge
  # @param [Boolean] capture should the transaction be captured?
  def self.authorize(payment_method, amount: nil, capture: false, metadata: {})
    raise unless payment_method # just in case for now

    service = CardConnect::Service::Authorization.new
    request_params = build_params_from_payment_method(payment_method).tap do |params|
      params['amount'] = amount.to_s
      params['capture'] = capture ? 'Y' : 'N'
      params['currency'] = 'USD'
      params['merchid'] = credentials[:merchant_id]
      params['orderid'] = [Rails.env, payment_method.id].join('-')

      if metadata.present?
        params['userfields'] = [].tap do |_meta|
          { 'po_number' => metadata[:po_number] } if metadata[:po_number]
        end
      end
    end
    service.build_request(request_params)
    service.submit
  end

  def self.build_params_from_payment_method(record)
    {}.tap do |param|
      param['ecomind'] = PAYMENT_TRIGGER_ECOMMERCE # R - recurring  |  E - ecommerce/Internet
      param['profile'] = detect_profile_value_to_use(record)
      break param unless param['profile'] == 'Y'

      if record.payment_type == :credit
        param['account'] = record.credit_card_token
        param['expiry'] = record.credit_card_expiration_date
        param['cvv2'] = record.credit_card_cvv
      elsif record.payment_type == :ach
        param['account'] = record.ach_account_token
        # param['bankaba'] = record.ach_routing_number  # we don't independently have this, hoping the token is good enough
        param['name'] = record.ach_account_name

        ## TEMP HACK FOR GEM BUG
        param['expiry'] = '1250' # 12/50
        ## TEMP HACK FOR GEM BUG
      else
        raise "Invalid Payment Type for processing"
      end

      # AVS fields
      if record.address
        param['address'] = record.address.street1
        param['city'] = record.address.city
        param['postal'] = record.address.zip
        param['region'] = record.address.state
      end
      param['email'] = record.billing_contact.email if record.billing_contact
    end
  end

  def self.detect_profile_value_to_use(record)
    record.customer_vault_id = record.customer_vault_id.presence || 'Y'
  end
end
