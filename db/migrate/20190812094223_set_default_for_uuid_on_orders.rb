class SetDefaultForUuidOnOrders < ActiveRecord::Migration[5.2]
  def change
    change_column_default :orders, :uuid, 'gen_random_uuid()'
    # ActiveRecord::Base.connection.execute("update orders set uuid = gen_random_uuid()")
  end
end
