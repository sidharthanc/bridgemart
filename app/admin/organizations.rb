ActiveAdmin.register Organization do
  actions :index, :show, :edit, :update, :destroy

  filter :name_contains, label: 'NAME', as: :string
  filter :industry_contains, label: 'INDUSTRY', as: :string
  filter :created_at, label: 'CREATED AT', as: :date_range
  filter :updated_at, label: 'UPDATED AT', as: :date_range
  filter :purchase_instructions_contains, label: 'PURCHASE INSTRUCTIONS', as: :string
  filter :legacy_identifier_contains, label: 'LEGACY IDENTIFIER', as: :string

  permit_params :name, :industry, :purchase_instructions, :primary_user_id, :logo

  form partial: 'form'

  controller do
    def destroy
      organization = Organization.find(params.fetch(:id))
      Organizations::DeleteOrganizationJob.perform_later(organization)
      redirect_to admin_organizations_path, notice: I18n.t('active_admin.organizations.delete_job_message')
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_organizations_path, notice: I18n.t('active_admin.organizations.record_not_exist')
    end

    def scoped_collection
      super.includes :primary_user
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :industry
    column :purchase_instructions
    column :legacy_identifier
    column :created_at
    column :number_of_employees
    column :number_of_employees_with_safety_rx_eyewear
    column :primary_user
    actions
  end

  show do
    attributes_table do
      row(:name)
      row(:industry)
      row :logo do |organization|
        attached_image_tag(organization.logo)
      end
      row(:primary_user)
      row(:number_of_employees)
      row(:created_at)
    end
    active_admin_comments
  end
end
