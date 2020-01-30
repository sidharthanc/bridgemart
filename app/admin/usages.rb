ActiveAdmin.register Usage do
  actions :index, :show
  remove_filter :audits, :code, :member, :created_at,
                :updated_at, :activity, :result, :reason, :notes, :amount_currency,
                :total_usage_cents, :total_usage_currency, :total_per_visit_cents, :retail_price_cents,
                :retail_price_curreny, :upc_number, :upc_category, :upc_description, :company_type,
                :transaction_detail_identifier, :deleted_at

  controller do
    def scoped_collection
      super.includes code: :organization
    end
  end

  index do
    selectable_column
    id_column
    column :code_id
    column :organization do |usage|
      usage.code.organization.id
    end
    column :used_at
    column :created_at
    column :amount_cents
    column :amount_currency
    column :visit_number
    column :store_city
    column :store_state
    column :store_number
    column :external_id
    column :department_category
    actions
  end

  show do
    attributes_table do
      row(:code_id)
      row(:organization) do |usage|
        usage.code.organization.id
      end
      row(:used_at)
      row(:created_at)
      row(:amount_cents)
      row(:amount_currency)
      row(:visit_number)
      row(:store_city)
      row(:store_state)
      row(:store_number)
      row(:external_id)
      row(:department_category)
    end
    active_admin_comments
  end

  csv do
    column :id
    column :code_id
    column :organization do |usage|
      usage.code.organization.id
    end
    column :used_at
    column :created_at
    column :amount_cents
    column :amount_currency
    column :visit_number
    column :store_city
    column :store_state
    column :store_number
    column :external_id
    column :department_category
  end
end
