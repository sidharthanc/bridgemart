class MembersController < DashboardController
  before_action :set_member, only: %i[show edit update destroy deactivate reactivate resend balance_inquiry]

  def index
    @search = current_organization.members.ransack(params[:q])
    @search.sorts = 'created_at DESC' if @search.sorts.empty?
    @members = @search.result.chronological

    respond_with @members do |format|
      format.html { @pagy, @members = paginate @members }
      format.csv do
        export = MemberExport.new(@members, current_organization)
        send_data export.csv, filename: "#{export.filename}.csv"
      end
    end
  end

  def show
    edit
    render :edit
  end

  def usages_export
    search = current_organization.members.includes(:usages).ransack(params[:q])
    members = search.result
    usage_ids = members.map(&:usage_ids)
    @usages = Usage.where(id: usage_ids.flatten).includes(code: %i[order member])
    respond_with members do |format|
      format.csv do
        export = UsageExport.new(@usages)
        send_data export.csv, filename: "#{export.filename}.csv"
      end
    end
  end

  def edit
    @plan = @member.plan
    @member.build_address unless @member.address
  end

  def update
    @member.attributes = permitted_params
    authorize @member
    member_session.store @member if @member.save
    respond_with @member, location: organization_member_path(current_organization, @member)
  end

  def balance_inquiry
    update_balances
    edit
  end

  def deactivate
    @member.deactivate
    @member.codes.each(&:deactivate)
    MemberMailer.deactivate_member(@member).deliver_later
    respond_with @member, location: organization_member_path(current_organization, @member)
  end

  def reactivate
    @member.reactivate
    respond_with @member, location: organization_member_path(current_organization, @member)
  end

  def resend
    CodeMailer.registered_email(@member).deliver_later
  end

  protected
    helper_method def member_session
      @member_session ||= MemberSession.new session
    end

    def navigation
      Enrollment::Navigation.new '#', new_order_payment_path(@order)
    end

  private
    def set_member
      @member = policy_scope(current_organization.members).find params[:id]
      authorize @member
    end

    def update_balances
      @member.codes.each do |code|
        next if code.card_number.blank? || (code.balance.zero? && code.deactivated_at.present?) || code.fields&.empty? || code.product_category.card_type == 'eml'

        ClosedLoop::Transactions::BalanceInquiry.new(card_number: code.card_number, ean: FirstData::Encryption.encrypt_ean(code.pin)).perform
      end
    end

    def permitted_params
      params
        .require(:member)
        .permit :first_name, :middle_name, :last_name, :email, :phone,
                :external_member_id, address_attributes: %i[id street1 city state zip]
    end
end
