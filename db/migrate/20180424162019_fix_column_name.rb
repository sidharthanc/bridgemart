class FixColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :plans, :end_time, :ends_on
    rename_column :plans, :start_date, :starts_on
  end
end
