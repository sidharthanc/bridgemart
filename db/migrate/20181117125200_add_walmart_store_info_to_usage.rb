class AddWalmartStoreInfoToUsage < ActiveRecord::Migration[5.2]
  def change
    add_column :usages, :visit_number, :string
    add_column :usages, :store_city, :string
    add_column :usages, :store_state, :string
    add_monetize :usages, :total_usage
    add_monetize :usages, :total_per_visit
    add_monetize :usages, :retail_price
    add_column :usages, :store_number, :string
    add_column :usages, :department_category, :string
    add_column :usages, :upc_number, :string
    add_column :usages, :upc_description, :string
    add_column :usages, :company_type, :string
  end
end
