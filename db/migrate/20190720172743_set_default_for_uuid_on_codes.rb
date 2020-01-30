class SetDefaultForUuidOnCodes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :codes, :uuid, 'gen_random_uuid()'
    # ActiveRecord::Base.connection.execute("update codes set uuid = gen_random_uuid()")
  end
end
