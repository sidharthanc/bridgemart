class CreateUsageImports < ActiveRecord::Migration[5.2]
  def change
    create_table :usage_imports do |t|
      t.json :problems
      t.timestamps
    end
  end
end
