class BackportUseOrganizationBrandingDefaultOnProductCategory < ActiveRecord::Migration[5.2]
  def change
    say_with_time "Backport product_categories.use_organization_branding default" do
      ProductCategory.unscoped.select(:id).find_in_batches.with_index do |batch, index|
        say("Processing batch #{index}\r", false)
        ProductCategory.unscoped.where(id: batch).update_all(use_organization_branding: false)
      end
    end
  end
end
