class AddBrokerOrganizationNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :broker_organization_name, :string
  end
end
