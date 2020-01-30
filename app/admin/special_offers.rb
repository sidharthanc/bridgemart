ActiveAdmin.register SpecialOffer do
  permit_params :name, :description, :usage_instructions, :image, :product_category_id

  show do
    default_main_content do
      row(:image) { attached_image_tag(special_offer.image) }
    end
  end

  controller do
    rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

    def invalid_foreign_key
      redirect_to admin_special_offers_path, alert: t('.errors.invalid_foreign_key')
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
      f.input :description
      f.input :usage_instructions
      f.input :image, as: :file, input_html: { accept: 'image/*' }
      f.input :product_category, include_blank: false
    end

    f.actions
  end
end
