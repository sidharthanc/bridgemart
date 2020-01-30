class AddPurchaseInstructionsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :purchase_instructions, :text
  end
end
