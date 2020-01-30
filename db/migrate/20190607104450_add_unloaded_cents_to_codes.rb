class AddUnloadedCentsToCodes < ActiveRecord::Migration[5.2]
  def self.up
    add_column :codes, :unloaded_amount_cents, :integer
  end

  def self.down
    remove_column :codes, :unloaded_amount_cents
  end
end
