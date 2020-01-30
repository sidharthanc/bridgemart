ActiveAdmin.register PermissionGroup do
  permit_params :name, :admin, :default_for, owned_permission_group_ids: []

  controller do
    include MassAssignable

    before_action :associate_new_with_user, only: :create
    before_action :filter_permission_groups, only: %i[create update]

    def associate_new_with_user
      current_user.permission_groups << build_resource
    end

    def filter_permission_groups
      prevent_unauthorized_mass_assignment!(
        params: params[:permission_group],
        attribute: :owned_permission_group_ids,
        scope: owned_permission_groups
      )
    end

    def owned_permission_groups
      resource.owned_permission_groups
    rescue ActiveRecord::RecordNotFound
      PermissionGroup.none
    end
  end

  show do
    default_main_content do
      panel 'Editable Permission Groups' do
        table_for permission_group.owned_permission_groups do
          column :name
          column :admin
          column :default_for
        end
      end
    end
  end

  form do |form|
    form.semantic_errors

    form.inputs do
      form.input :name
      form.input :admin
      form.input :default_for
      form.input :owned_permission_groups, collection: policy_scope(PermissionGroup.all)
    end

    form.actions
  end

  sidebar 'Details', only: %i[show edit] do
    ul do
      li link_to 'Permissions', admin_permission_group_permissions_path(resource)
    end
  end
end
