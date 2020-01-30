module ApplicationHelper
  include Memoizer
  include Pagy::Frontend
  def in_layout(layout)
    view_flow.set :layout, capture { yield }
    render template: "layouts/#{layout}"
  end

  def active_link_to(text, href, options = {})
    if Array.wrap(options[:activate]).any? { |path| current_page?(path == :self ? href : path) }
      options[:class] ||= ''
      options[:class] += ' active'
      options[:class].strip!
    end

    link_to text, href, options
  end

  def redemption_instruction_collection(organization, product_category)
    collection = RedemptionInstruction.where(organization: organization, product_category: product_category)
    collection += [RedemptionInstruction.new(id: 0, title: t('helpers.new_redemption_instruction'))] if current_user.can_access_org?(organization)
    proc { collection.map { |ri| [ri.title, ri.id, { 'data-description' => ri.description }] } }
  end
  memoize :redemption_instruction_collection

  def current_redemption_instruction(organization, product_category)
    organization.redemption_instructions.order(active: :desc).find_by(product_category_id: product_category.id)
  end
  memoize :current_redemption_instruction

  def code_redemption_instruction(code, organization)
    code.product_category.redemption_instructions.where(organization: organization, active: true).first
  end

  def attached_image_tag(attached_image, options = {})
    image_tag(attached_image, options) if attached_image.attached?
  end
  memoize :attached_image_tag

  def link_to_credit_purchase_print(organization, credit_purchase)
    link_to I18n.t(:print), organization_credit_purchase_print_path(organization, credit_purchase)
  end

  def link_to_credit_purchase_edit(organization, credit_purchase)
    return unless credit_purchase.editable?

    link_to I18n.t(:edit), edit_organization_credit_purchase_path(organization, credit_purchase)
  end

  def link_to_credit_purchase_pay(organization, credit_purchase)
    return unless credit_purchase.payable?

    link_to I18n.t(:pay), organization_credit_purchase_pay_path(organization, credit_purchase), method: :patch, data: { behavior: 'no-expand', confirm: t('.confirm_pay') }
  end

  def link_to_credit_purchase_void(organization, credit_purchase)
    return unless credit_purchase.voidable?

    link_to I18n.t(:void), organization_credit_purchase_void_path(organization, credit_purchase), method: :patch, data: { behavior: 'no-expand', confirm: t('.confirm_void') }
  end

  def asset_data_base64(path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def show_attached_image(attachment, options = {})
    image_tag(rails_blob_url(attachment), options) if attachment.attached?
  end
end
