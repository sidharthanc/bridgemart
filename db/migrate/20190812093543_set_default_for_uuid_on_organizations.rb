class SetDefaultForUuidOnOrganizations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :organizations, :uuid, 'gen_random_uuid()'
    # ActiveRecord::Base.connection.execute("update organizations set uuid = gen_random_uuid()")
  end
end
