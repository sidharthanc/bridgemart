class AddUuidToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :uuid, :uuid
  end
end
