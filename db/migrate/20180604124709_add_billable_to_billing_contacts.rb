class AddBillableToBillingContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :billing_contacts, :billable, polymorphic: true
  end
end
