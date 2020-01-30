class AddEMLFieldsToUsages < ActiveRecord::Migration[5.2]
  def change
    add_column :usages, :activity, :string
    add_column :usages, :reason, :string
    add_column :usages, :result, :string
    add_column :usages, :notes, :string
    add_column :usages, :used_at, :datetime
    add_column :usages, :external_id, :string
  end
end
