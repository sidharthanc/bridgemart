class CreateBillingContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_contacts do |t|
      t.references :plan, index: true

      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :role

      t.timestamps
    end
  end
end
