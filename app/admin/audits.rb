ActiveAdmin.register Audited.audit_class, as: 'Audit Log' do
  actions :index, :show
  preserve_default_filters!
  remove_filter :associated_type, :username, :comment, :request_uuid, :version, :user_type, :user_email
  filter :user_id_eq, label: 'User ID'

  controller do
    def scoped_collection
      super.includes :auditable, :user
    end
  end

  controller do
    def scoped_collection
      super.includes :auditable, :user
    end
  end

  controller do
    def scoped_collection
      super.includes :auditable, :user
    end
  end

  index do
    column :id
    column :auditable
    column :auditable_type
    column :user
    column(:user_email) { |audited| audited.user.email if audited.user.present? }
    column :user_type
    column :action
    column :audited_changes
    column :version
    column :comment
    column :created_at
    actions
  end

  csv do
    column :id
    column :auditable
    column :auditable_type
    column(:user_email) { |audited| audited.user.email if audited.user.present? }
    column(:user_id)
    column(:username) { |audited| audited.user.full_name if audited.user.present? }
    column :user_type
    column :action
    column :audited_changes
    column :version
    column :comment
    column :created_at
  end

  show do
    attributes_table do
      row :id
      row :auditable
      row :auditable_type
      row :user
      row :user_type
      row :action
      row :audited_changes
      row :version
      row :comment
      row :created_at
    end
  end
end
