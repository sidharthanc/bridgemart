class CreateCommercialAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :commercial_agreements, &:timestamps
  end
end
