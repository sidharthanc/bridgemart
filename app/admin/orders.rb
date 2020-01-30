ActiveAdmin.register Order do
  actions :index, :show
  preserve_default_filters!

  remove_filter :audits, :line_items, :plan, :payment_method, :address, :billing_contact, :member_imports, :codes, :members, :plan_product_categories, :pdf_attachment, :pdf_blob, :statistics
  # filter :members_in, as: :select, label: "Members", collection: proc { Member.includes(:order).map { |mem| ["#{mem.first_name} #{mem.middle_name} #{mem.last_name}", mem.id] }.uniq }
  filter :plan_product_categories_in, as: :select, label: "Plan Product Categories", collection: proc { ProductCategory.pluck("name", "id") }

  controller do
    def scoped_collection
      super.includes :organization, :payment_method, :plan_product_categories
    end
  end

  index do
    selectable_column
    id_column
    column(:organization) { |order| order.organization.name }
    column :processed_at
    column :paid_at
    column :starts_on
    column :ends_on
    column :po_number
    column :payment_method
    column :amount_cents, &:formatted_total
    column :amount_currency
    actions
  end

  show do
    attributes_table do
      row(:organization) { |order| order.organization.name }
      row :paid_at
      row :starts_on
      row :ends_on
      row :po_number
      row :payment_method
      row :amount_cents, &:formatted_total
      row :amount_currency
      row :paid
      row :transaction_number
    end
    active_admin_comments
  end

  csv do
    column :id
    column (:organization) { |order| order.organization.name }
    column :processed_at
    column :starts_on
    column :ends_on
    column :po_number
    column (:amount_cents) { |order| order.formatted_total }
    column :amount_currency
  end
end
