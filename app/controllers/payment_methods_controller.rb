class PaymentMethodsController < DashboardController
  before_action :find_payment_method, only: %i[edit confirm]

  def index
    @pagy, @payment_methods = pagy(current_organization.payment_methods.chronological, page: params[:page])
    @can_edit_payment_method = policy(PaymentMethod).edit?
  end

  def edit
    @primary_user = current_organization.primary_user
  end

  def create
    @payment_method = current_organization.build_payment_method(payment_method_attributes)
    @payment_method.address_attributes = address_attributes
    @payment_method.billing_contact_attributes = billing_contact_attributes
    @payment_method.save!

    respond_with @payment_method, location: -> { edit_organization_payment_method_path(current_organization, @payment_method) }
  end

  def confirm
    response = PaymentService.authorize @payment_method, amount: 0

    unless response.success?
      flash[:alert] = response.errors
      redirect_to edit_organization_payment_method_path(current_organization, @payment_method)
      return
    end
    redirect_to organization_payment_methods_path(current_organization)
  end

  private
    def find_payment_method
      @payment_method = PaymentMethod.find(params[:id])
      authorize @payment_method
    end

    def payment_method_params
      params.require(:payment_method)
            .permit(:first_name, :last_name, :email,
                    :street1, :street2, :city, :state, :zip,
                    :ach_account_name, :ach_account_type, :ach_account_token,
                    :credit_card_token, :credit_card_cvv, :credit_card_expiration_date)
    end

    def address_attributes
      payment_method_params.slice(:street1, :street2, :city, :state, :zip)
    end

    def billing_contact_attributes
      payment_method_params.slice(:first_name, :last_name, :email)
    end

    def payment_method_attributes
      payment_method_params.slice(:ach_account_name, :ach_account_type, :ach_account_token, :credit_card_token, :credit_card_cvv, :credit_card_expiration_date)
    end
end
