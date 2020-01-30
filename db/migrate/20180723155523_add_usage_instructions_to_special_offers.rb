class AddUsageInstructionsToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :usage_instructions, :text
  end
end
