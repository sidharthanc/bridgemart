class SetDefaultForUuidOnMembers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :members, :uuid, 'gen_random_uuid()'
    # ActiveRecord::Base.connection.execute("update members set uuid = gen_random_uuid()")
  end
end
