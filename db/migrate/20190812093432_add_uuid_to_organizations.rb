class AddUuidToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :uuid, :uuid
  end
end
