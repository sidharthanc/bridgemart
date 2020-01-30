class AddCommercialAgreementsToPlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :plans, :commercial_agreement, index: true
  end
end
