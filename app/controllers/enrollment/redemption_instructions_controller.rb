class Enrollment::RedemptionInstructionsController < Enrollment::BaseController
  respond_to :json
  before_action :find_order

  def new
    @redemption_instruction = RedemptionInstruction.new
  end

  def create
    @redemption_instruction = @order.organization.redemption_instructions.new(permitted_params)
    authorize @redemption_instruction
    @redemption_instruction.save
    respond_with @redemption_instruction
  end

  def index
    respond_with @order.organization.redemption_instructions.where(product_category_id: params[:product_category_id])
  end

  private
    def permitted_params
      params.require(:redemption_instruction).permit(:title, :description, :product_category_id, :active)
    end

    def find_order
      @order = policy_scope(::Order).find params[:order_id]
      authorize @order, :create?
    end
end
