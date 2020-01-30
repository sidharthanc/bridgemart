module Enrollment
  class PaymentsController < BaseController
    layout 'enrollment'
    respond_to :json

    def new
      flash.now[:alert] = order.error_message if order.error_message.present?
      @payment = Payment.new order: order
      prefill_billing_contact_from_user(@payment, order.primary_user) if signed_in?
      prefill_billing_information_from_billing_id(@payment, params[:billing_id]) # if params[:billing_id].present?
      order.build_payment_method if order.payment_method.blank?
      params[:organization_id] = order.organization.id
    end

    def create
      order.update!(processed_at: nil, applied_credit: applied_credit, notes: params.dig(:payment, :notes), po_number: params.dig(:payment, :po_number))
      if purchase_is_entirely_accrued_credit?
        PaymentJob.perform_later order
        respond_with order, location: -> { process_order_enrollment_order_payments_path(order) }
      else
        @payment = Payment.new permitted_params
        @payment.order = order
        PaymentJob.perform_later(order) if @payment.valid? && @payment.save
        respond_with @payment, location: -> { process_order_enrollment_order_payments_path(order) }
      end
    end

    # Process Order is a holding page until the order is fullfilled.
    def process_order
      order
      respond_to do |format|
        format.html # process_order.html.erb
        format.json { render json: order }
      end
    end

    def confirm
      if order.processed_at.present?
        redirect_to(dashboard_path) && return if order.paid?

        flash[:alert] = order.error_message || t('.error_occured')
        redirect_to new_enrollment_order_payment_path(order, billing_id: order.payment_method&.id)
      else # still processing, wait for job to finish
        redirect_to process_order_enrollment_order_payments_path(order)
      end
    end

    protected
      def navigation
        Enrollment::Navigation.new new_enrollment_order_member_path(order), dashboard_path
      end

    private
      def prefill_billing_contact_from_user(payment, user)
        payment.first_name = user.first_name
        payment.last_name = user.last_name
        payment.email = user.email
        payment.terms_and_conditions = order.organization.has_signed CommercialAgreement.last
      end

      def prefill_billing_information_from_billing_id(payment, billing_id)
        payment.billing_id = billing_id
        payment.payment_method = payment.payment_method_from_billing_id(billing_id, order.organization)
      end

      def using_accrued_credits?
        permitted_params[:payment_type] == PaymentMethod::PAYMENT_TYPE_ACCRUED_CREDIT && applied_credit.positive?
      end

      def purchase_is_entirely_accrued_credit?
        using_accrued_credits? && order.organization.credit_amount_available?(order.total)
      end

      def applied_credit
        params.dig(:applied_credit).present? ? params.dig(:applied_credit).to_f : 0.0
      end

      def order
        @order ||= begin
          policy_scope(Order).find_by!(id: params[:order_id])
        end
        authorize @order
        @order
      end

      def permitted_params
        params
          .require(:payment)
          .permit(:billing_id, :terms_and_conditions, :po_number, :applied_credit, :notes,
                  :street1, :street2, :city, :state, :zip,
                  :email, :first_name, :last_name,
                  :payment_type,
                  :credit_card_token, :credit_card_expiration_date, :credit_card_cvv,
                  :ach_account_name, :ach_account_token, :ach_account_type)
      end
  end
end
