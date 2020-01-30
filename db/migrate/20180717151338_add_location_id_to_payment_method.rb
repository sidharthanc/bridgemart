class AddLocationIdToPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_methods, :location, foreign_key: true, index: true
  end
end
