class AddDeliveredToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :delivered, :boolean, default: false, null: false
  end
end
