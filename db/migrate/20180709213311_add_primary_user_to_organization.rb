class AddPrimaryUserToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :primary_user_id, :integer

    Organization.find_each do |organization|
      primary_user_assignment(organization)
    end

    add_index :organizations, :primary_user_id
    add_foreign_key :organizations, :users, column: :primary_user_id, primary_key: :id
  end

  # Moved from Organization#primary_user
  def primary_user_assignment(organization)
    return unless (user = organization.users.with_default_permission_for_organization.first)

    organization.update primary_user_id: user.id
  end
end
