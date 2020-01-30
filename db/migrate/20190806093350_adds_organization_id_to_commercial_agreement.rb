class AddsOrganizationIdToCommercialAgreement < ActiveRecord::Migration[5.2]
  def change
    add_column :commercial_agreements, :organization_id, :integer
  end
end
