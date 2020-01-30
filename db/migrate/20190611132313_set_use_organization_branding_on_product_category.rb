class SetUseOrganizationBrandingOnProductCategory < ActiveRecord::Migration[5.2]
  def change
    change_column_default :product_categories, :use_organization_branding, from: nil, to: false
  end
end
