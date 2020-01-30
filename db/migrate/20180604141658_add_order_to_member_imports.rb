class AddOrderToMemberImports < ActiveRecord::Migration[5.2]
  def change
    add_reference :member_imports, :order, foreign_key: true
  end
end
