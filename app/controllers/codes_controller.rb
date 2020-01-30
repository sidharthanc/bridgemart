class CodesController < DashboardController
  include Ransackable
  before_action :set_member, only: :index
  before_action only: :index do
    adjust_ransack_date_range_for_attribute(params, :created_at)
  end
  before_action only: :index do
    adjust_ransack_date_range_for_attribute(params, :deactivated_at)
  end
  before_action :set_code, only: %i[unlock lock deactivate]

  def index
    @search = @member.codes.joins(:order).ransack(params[:q])
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @pagy, @codes = paginate authorized(@search.result.includes(:organization, :usages, :product_category))
  end

  def lock
    change_code_status(:lock, :locking, params[:reason])
  end

  def unlock
    change_code_status(:unlock, :unlocking, params[:reason])
  end

  def deactivate
    @code.deactivate
    respond_with @code, location: organization_member_codes_path(@code.organization, @code.member)
  end

  private
    def set_member
      @member = Member.find params[:member_id]
    end

    # Changes the Code status based on the request
    def change_code_status(oper, status, reason)
      @code.update(status: status)
      @code.send(oper, reason)
      respond_with @code, location: request.referrer
    end

    def set_code
      @code = Code.find params[:id]
      authorize @code
    end
end
