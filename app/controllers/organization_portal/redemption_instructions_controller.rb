class OrganizationPortal::RedemptionInstructionsController < OrganizationPortalController
  before_action :find_organization
  before_action :find_redemption_instruction, only: %i[show edit update destroy]

  def new
    @redemption_instruction = @organization.redemption_instructions.new
    authorize @redemption_instruction
  end

  def create
    @redemption_instruction = @organization.redemption_instructions.new(permitted_params)
    authorize @redemption_instruction
    @redemption_instruction.save
    respond_with @redemption_instruction, location: organization_redemption_instructions_path(current_organization)
  end

  def edit
    authorize @redemption_instruction
  end

  def update
    @redemption_instruction.assign_attributes(permitted_params)
    @redemption_instruction.update(permitted_params)
    respond_with @redemption_instruction, location: organization_redemption_instructions_path(current_organization)
  end

  def show
    authorize @redemption_instruction
  end

  def index
    @product_categories = @organization.product_categories_for_redemption_instructions
    @redemption_instructions = current_organization.redemption_instructions.includes(:product_category)
    authorized(@redemption_instructions)
  end

  def destroy
    authorize @redemption_instruction
    @redemption_instruction.destroy!
    redirect_to organization_redemption_instructions_path(current_organization), notice: "Delete success"
  end

  private
    def find_organization
      @organization = ::Organization.find(params[:organization_id])
    end

    def find_redemption_instruction
      @redemption_instruction = RedemptionInstruction.find(params[:id])
      authorize @redemption_instruction
    end

    def permitted_params
      params.require(:redemption_instruction).permit(:title, :description, :product_category_id, :active).merge(active: active_param)
    end

    def active_param
      ActiveModel::Type::Boolean.new.cast(params[:redemption_instruction][:active])
    end
end
