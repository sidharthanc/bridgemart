ActiveAdmin.register ProductCategory do
  permit_params :name, :single_use_only, :description, :icon, :image, :background_color,
                :tooltip_description, :card_type, :division_id, :product_bin,
                :product_description, :default_redemption_instructions,
                :redemption_instructions_editable, :fee_type, :percentage_fee,
                :flat_fee, :hidden, :use_organization_branding,
                price_points_attributes: %i[id limit verbiage note tooltip upgrade_verbiage item_name]

  remove_filter :audits

  controller do
    def scoped_collection
      super.includes :division
    end
  end

  show do
    attributes_table do
      row(:name)
      row(:single_use_only)
      row(:division)
      row(:icon) { attached_image_tag(product_category.icon) }
      row(:image) { attached_image_tag(product_category.image) }
      row(:description)
      row(:tooltip_description)
      row(:product_description)
      row(:default_redemption_instructions)
      row(:card_type)
      row(:product_bin)
      row(:redemption_instructions_editable)
      row(:fee_type)
      row(:flat_fee) { product_category.flat_fee } if product_category.flat_rate?
      row(:percentage_fee) { number_to_percentage product_category.percentage_fee, significant: true } if product_category.percentage_rate?
      row(:created_at)
      row(:updated_at)
      row(:background_color)
      row(:hidden)
      row(:use_organization_branding)
    end

    panel 'Price Points' do
      table_for product_category.price_points do
        %i[id limit verbiage note tooltip upgrade_verbiage item_name].map { |attr| column attr }
      end
    end
  end

  index do
    selectable_column

    ProductCategory.column_names.each do |c|
      id_column if c == 'id'
      if c == 'division_id'
        column :division do |product_category|
          division = product_category.division
          link_to division.name, admin_division_path(division)
        end
      end
      column c.to_sym unless c == 'id' || c == 'division_id'
    end

    actions do |product_category|
      if product_category.visible?
        link_to t('.deactivate'), deactivate_admin_product_category_path(product_category.id), method: :put
      else
        link_to t('.activate'), activate_admin_product_category_path(product_category.id), method: :put
      end
    end
  end

  member_action :activate, method: :put do
    resource.visible!
    redirect_to admin_product_categories_path, notice: t('.notice')
  end

  member_action :deactivate, method: :put do
    resource.hidden!
    redirect_to admin_product_categories_path, notice: t('.notice')
  end

  controller do
    rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

    def invalid_foreign_key
      redirect_to admin_product_categories_path, alert: t('.errors.invalid_foreign_key')
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
      f.input :single_use_only
      f.input :division, include_blank: false
      f.input :icon, as: :file, input_html: { accept: 'image/*' }
      f.input :image, as: :file, input_html: { accept: 'image/*' }
      f.input :description
      f.input :tooltip_description
      f.input :product_description
      f.input :default_redemption_instructions
      f.input :card_type, as: :select, collection: ['first_data', 'eml', 'legacy']
      f.input :product_bin
      f.input :redemption_instructions_editable
      f.input :fee_type
      f.input :flat_fee
      f.input :percentage_fee
      f.input :background_color
      f.input :hidden
      f.input :use_organization_branding
    end

    f.inputs do
      f.has_many :price_points, heading: 'Price Points' do |ff|
        ff.input :limit
        ff.input :verbiage
        ff.input :note
        ff.input :tooltip
        ff.input :upgrade_verbiage
        ff.input :item_name
      end
    end

    f.actions
  end
end
