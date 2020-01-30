ActiveAdmin.register Credit do
  actions :all, except: :destroy
  permit_params :source_id, :source_type, :amount_cents, :amount_currency, :organization_id
  remove_filter :audits
  filter :source_type_cont, label: 'SOURCE TYPE', as: :string
  filter :organization_name_cont, label: 'ORGANIZATION', as: :string
  filter :amount_cents_eq, label: 'AMOUNT CENTS', as: :string
  filter :amount_currency_cont, label: 'AMOUNT CURRENCY', as: :string
  filter :created_at, label: 'CREATED AT', as: :date_range
  filter :organization_id_eq, label: 'ORGANIZATION ID', as: :string

  controller do
    def scoped_collection
      super.includes :organization
    end

    def cancel
      credit = Credit.find(params.fetch(:format))
      credit.cancel
      redirect_to admin_credits_path, notice: I18n.t('active_admin.credits.cancel_message')
    end
  end

  action_item :cancel, only: :show do
    if credit.cancelable?
      link_to 'Cancel Credit', admin_credits_cancel_path(credit), method: :post
    end
  end

  index do
    column "Organization Id" do |credit|
      credit.organization.id if credit&.organization&.name
    end
    column :organization, sortable: 'organizations.name'
    column :amount_cents
    column :amount_currency
    column :source do |record| [record.source_type&.titleize || 'Unknown Source', record.source_id].join(' ') end
    actions
  end

  show do
    attributes_table do
      row(:source)
      row(:amount_cents)
      row(:amount_currency)
      row "Organization ID" do |credit|
        credit.organization.id if credit&.organization&.name
      end
      row(:organization)
      row(:created_at)
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :source,
              label: 'Credit Source',
              collection: Organization.all
      f.input :source_type,
              as: :hidden,
              input_html: { value: 'Organization' }
      f.input :amount_cents,
              input_html: { onkeypress: 'return event.charCode >= 48', oninput: "validity.valid||(value='')" }
      f.input :amount_currency
      f.input :organization
    end

    f.actions
  end

  csv do
    column :id
    column :source_type
    column :amount_cents
    column :amount_currency
    column :created_at
    column :updated_at
    column :deleted_at
    column "Organization ID" do |credit|
      credit.organization.id if credit&.organization&.id
    end
    column "Organization Name" do |credit|
      credit.organization.name if credit&.organization&.name
    end
  end
end
