class Enrollment::MembersController < Enrollment::BaseController
  authenticated!

  before_action :set_member, only: %i[edit update]

  def new
    @member = ::Member.new
    @member.build_address
    @add_member = params[:add_member]
    @search = order.organization.members.ransack(params[:q])
    @members = @search.result unless params[:q].nil?
    params[:organization_id] = order.organization.id
  end

  def create
    @member = order.members.build permitted_params
    save_member
    params[:organization_id] = order.organization.id
    respond_with @member, location: new_enrollment_order_member_path(order, mode: :manual, anchor: 'member-form')
    Members::GenerateBarcodeJob.perform_later(@member) unless @member.external_member_id.blank?
  end

  def add
    @member = Member.find params[:member_id]
    order.members << @member
    member_session.store @member if order.save
    respond_with @member, location: new_enrollment_order_member_path(order, mode: :search)
  end

  def edit
    order
    @add_member = true
    render :new
  end

  def update
    @member.attributes = permitted_params
    save_member
    respond_with @member, action: :new, location: @path
    Members::GenerateBarcodeJob.perform_later(@member) unless @member.external_member_id.blank?
  end

  protected
    helper_method def member_session
      @member_session ||= MemberSession.new session
      @member_session.valid_members(order)
      @member_session
    end

    def navigation
      Enrollment::Navigation.new edit_enrollment_order_path(order), new_enrollment_order_payment_path(order)
    end

  private

    def permitted_params
      params
        .require(:member)
        .permit :first_name, :middle_name, :last_name, :email, :phone,
                :external_member_id, address_attributes: %i[id street1 city state zip]
    end

    def set_member
      @member ||= ::Member.find params[:id]
      authorize @member
    end

    def save_member
      if @member.save
        member_session.store(@member)
        @path = new_enrollment_order_member_path(order, mode: :manual, anchor: 'member-form')
      else
        order.reload
        @add_member = true
        return if @member.present?

        @path = edit_enrollment_order_member_path(order, mode: :manual, anchor: 'member-form')
      end
    end

    def order
      @order ||= begin
        policy_scope(Order).find_by!(id: params[:order_id])
      end
      authorize @order
      @order
    end
end
