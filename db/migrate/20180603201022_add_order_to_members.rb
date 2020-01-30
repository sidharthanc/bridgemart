class AddOrderToMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :members, :order, foreign_key: true
  end
end
