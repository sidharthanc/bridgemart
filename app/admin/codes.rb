ActiveAdmin.register Code do
  actions :index, :show
  permit_params :member_id, :plan_product_category, :limit, :balance, :delivered
  remove_filter :audits, :order, :usages, :credits, :member, :plan_product_category

  controller do
    def scoped_collection
      super.includes :member, :plan_product_category, :organization
    end
  end

  index do
    selectable_column
    id_column
    column :member do |code|
      link_to "#{code.member.first_name} #{code.member.last_name}", admin_member_path(code.member.id) if code.member.present?
    end
    column :plan_product_category
    column :limit
    column :balance
    column :card_provider do |code|
      code.plan_product_category.product_category.card_type.camelize
    end
    column :organization do |code|
      code.organization.name
    end
    column 'Order ID' do |code|
      code.order.id
    end
    column :legacy_identifier
    column :card_number
    column :pin
    column :created_at
    column :delivered
    actions
  end

  form do |f|
    f.inputs do
      f.input :member
      f.input :plan_product_category
      f.input :limit
      f.input :balance
      f.input :delivered
      f.input :legacy_identifier
    end
    f.actions
  end

  csv do
    column :id
    column :balance_cents
    column :limit_cents
    column :status
    column :card_number
    column :created_at
    column :updated_at
    column 'Order' do |code|
      code.order.id
    end
    column :deactivated_at
    column :authentication_token
    column :barcode_url
    column :card_image_url
    column :delivered
    column :legacy_identifier
    column :fields
    column :discarded_at
  end
end
