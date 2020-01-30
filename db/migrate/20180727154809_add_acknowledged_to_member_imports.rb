class AddAcknowledgedToMemberImports < ActiveRecord::Migration[5.2]
  def change
    add_column :member_imports, :acknowledged, :boolean, default: false, null: false
  end
end
