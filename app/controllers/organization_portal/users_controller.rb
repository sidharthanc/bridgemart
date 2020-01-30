class OrganizationPortal::UsersController < OrganizationPortalController
  include MassAssignable

  authenticated!
  before_action :find_user, only: %i[edit show update]
  before_action :filter_permission_groups, only: %i[create update]

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(permitted_params)
    authorize @user

    @user.organizations << current_organization
    UserSetup.new(@user).send_invitation_email
    respond_with @user, location: organization_users_path(current_organization)
  end

  def edit
  end

  def update
    @user.assign_attributes permitted_params.except(:email)
    authorize @user

    @user.save
    respond_with @user, location: organization_users_path(current_organization)
  end

  def show
  end

  def index
    @search = current_organization.users.ransack(params[:q])
    @pagy, @users = paginate authorized(@search.result)
    @users_count = current_organization.users.count
  end

  private
    def permitted_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :phone_number,
        permission_group_ids: []
      )
    end

    def find_user
      @user = User.find(params[:id])
      authorize @user
    end

    def filter_permission_groups
      return if @user.present? && @user.admin?

      prevent_unauthorized_mass_assignment!(
        params: params[:user],
        attribute: :permission_group_ids,
        scope: @user&.permission_groups || PermissionGroup.none
      )
    end
end
