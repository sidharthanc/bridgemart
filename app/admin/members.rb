ActiveAdmin.register Member do
  actions :index, :show, :edit, :update
  permit_params :first_name, :last_name, :order_id, :middle_name, :email, :phone
  preserve_default_filters!
  remove_filter :audits, :address, :order, :codes, :plan, :usages, :updated_at, :authentication_token, :external_member, :deleted_at

  index do
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone
    column :created_at
    column :deactivated_at
    actions
  end

  show do
    attributes_table do
      row(:id)
      row(:first_name)
      row(:last_name)
      row(:email)
      row(:phone)
      row(:created_at)
      row(:deactivated_at)
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
    end
    f.actions
  end
end
