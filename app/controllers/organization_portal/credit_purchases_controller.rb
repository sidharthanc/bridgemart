class OrganizationPortal::CreditPurchasesController < OrganizationPortalController
  before_action :find_organization
  before_action :find_credit_purchase, only: %i[pay print void]
  before_action :find_credit_purchase_by_id, only: %i[edit update]

  after_action :verify_authorized

  def index
    @pagy, @credit_purchases = paginate @organization.credit_purchases.includes(:payment_method)
    authorize @credit_purchases
  end

  def new
    @credit_purchase = CreditPurchase.new(organization: @organization, payment_method: @organization.payment_methods.last)
    authorize @credit_purchase
  end

  def create
    @credit_purchase = CreditPurchase.new permitted_params.merge(payment_method: @payment_method, organization: @organization)
    authorize @credit_purchase

    @credit_purchase.save

    respond_with @credit_purchase, location: organization_credit_purchases_path(@organization)
  end

  def edit
    @payment_method = @credit_purchase.payment_method
  end

  def update
    @credit_purchase.update permitted_params.merge(payment_method: @payment_method, organization: @organization)

    respond_with @credit_purchase, location: organization_credit_purchases_path(@organization)
  end

  def pay
    response = PaymentService.authorize(@credit_purchase.payment_method,
                                        amount: @credit_purchase.amount,
                                        capture: true,
                                        metadata: { po_number: @credit_purchase&.po_number })
    if response.success?
      @organization.credit_pool(amount: @credit_purchase.amount, source: @credit_purchase)
      @credit_purchase.paid!
    else
      @credit_purchase.update error_message: response.errors.join
    end
    redirect_to action: :index
  end

  def void
    @credit_purchase.void!
    redirect_to action: :index
  end

  def print; end

  def export
    credit_purchases = @organization.credit_purchases
    authorize credit_purchases
    respond_with credit_purchases do |format|
      format.csv do
        send_data credit_purchases.to_csv, filename: "credit-purchases-#{Date.current}.csv"
      end
    end
  end

  private
    def find_organization
      @organization = ::Organization.find(params[:organization_id])
    end

    def find_credit_purchase
      @credit_purchase = CreditPurchase.find(params[:credit_purchase_id])
      authorize @credit_purchase
    end

    def find_credit_purchase_by_id
      @credit_purchase = CreditPurchase.find(params[:id])
      authorize @credit_purchase
    end

    def permitted_params
      @payment_method = @organization.payment_methods.find(params.dig(:credit_purchase, :payment_method_id))
      params.require(:credit_purchase).permit(:po_number, :amount)
    end
end
