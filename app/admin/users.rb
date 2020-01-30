ActiveAdmin.register User do
  actions :all
  permit_params :first_name, :last_name, :email, :password, :use_enhanced_dashboard, :password_confirmation, permission_group_ids: [], organization_ids: []

  controller do
    include MassAssignable

    before_action :bypass_password_when_empty, only: :update
    before_action :filter_permission_groups, only: %i[create update]

    def destroy
      user = User.find(params.fetch(:id))
      user.destroy
      redirect_to admin_users_path, notice: I18n.t('active_admin.users.delete_message')
    end

    def bypass_password_when_empty
      if params[:user][:password].blank?
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end
    end

    def filter_permission_groups
      prevent_unauthorized_mass_assignment!(
        params: params[:user],
        attribute: :permission_group_ids,
        scope: permission_groups
      )
    end

    def permission_groups
      resource.permission_groups
    rescue ActiveRecord::RecordNotFound
      PermissionGroup.none
    end

    def scoped_collection
      super.includes :organizations
    end
  end

  action_item :destroy, only: :show do
    link_to 'Delete User', admin_user_path(user), method: :delete unless user.primary_user?
  end

  index do
    selectable_column
    id_column
    column(:total_organizations) { |user| user.organizations.size }
    column :email
    column :use_enhanced_dashboard
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    panel 'Organizations' do
      table_for user.organizations do
        column :name
        column :industry
        column :default
      end
    end
    default_main_content do
      panel 'Permission Groups' do
        table_for user.permission_groups do
          column :name
          column :admin
          column :default
        end
      end
    end
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :use_enhanced_dashboard
      f.input :password
      f.input :password_confirmation
      f.input :permission_groups, collection: policy_scope(PermissionGroup.all)
      f.input :organizations, as: :select
    end

    f.actions
  end
end
