class CreateOrganizationUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_users do |t|
      t.references :organization, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
