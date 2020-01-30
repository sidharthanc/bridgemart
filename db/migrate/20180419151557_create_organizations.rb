class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :industry
      t.string :number_of_employees

      t.timestamps null: false
    end
  end
end
