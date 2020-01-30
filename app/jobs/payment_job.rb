require 'rollbar'

class PaymentJob < ApplicationJob
  class PaymentAlreadyProcessed < RuntimeError; end
  class PaymentProcessingError < RuntimeError; end

  queue_as :high

  #  include Sidekiq::Worker
  #  sidekiq_options retry: 0 # Don't retry, but keep the failed job in the 'Dead' queue

  attr_reader :credit_purchase

  def perform(order)
    order.with_lock do
      if order.processed? || order.paid?
        Rollbar.error(PaymentAlreadyProcessed.new("Order already processed / paid"))
        return
      end
      order.deduct_credits(order.applied_credit) if order.applied_credit.present?
      if order.total_with_credits.zero?
        order.touch(:paid_at)
        payment_processed_successfully(order)
      else
        process(order)
      end
    end
  rescue StandardError => e
    Rollbar.error(PaymentProcessingError.new(e.message))
    ActiveRecord::Base.transaction(joinable: false) { order.update!(error_message: e.message) }
  ensure
    ActiveRecord::Base.transaction(joinable: false) { order.touch(:processed_at) }
  end

  private
    def process(order)
      order.with_lock do
        @credit_purchase = CreditPurchase.create!(payment_method: order.payment_method, organization: order.organization, amount: order.total_with_credits)
        response = ServiceActivity.record(self.class, :authorize) do |_|
          PaymentService.authorize(order.payment_method,
                                   amount: order.total_with_credits,
                                   capture: true,
                                   metadata: { po_number: order&.po_number })
        end
        if response.success?
          order.update(transaction_number: response.try(:retref))
          order.payment_method.update(customer_vault_id: response.try(:profileid))
          @credit_purchase.paid!
          order.touch(:paid_at)
        else
          @credit_purchase.update error_message: response.errors.join
          logger.debug response
          logger.debug order.error_message = response.errors.join
        end
        payment_processed_successfully(order) if response.success?
      end
    rescue RuntimeError => e
      Rollbar.error(e)
      @credit_purchase.update error_message: e.message
      order.error_message = e.message
    end

    def payment_processed_successfully(order)
      order.create_line_items
      InvoiceMailer.enrollment_invoice_email(order).deliver_later
      Orders::GenerateCodesJob.perform_later(order) if starts_immediately?(order)
    end

    def starts_immediately?(order)
      order.starts_on <= Date.current.at_midnight
    end
end
