class AddUseOrganizationBrandingToProductCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :use_organization_branding, :boolean
  end
end
