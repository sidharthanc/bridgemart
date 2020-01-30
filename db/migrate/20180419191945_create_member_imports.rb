class CreateMemberImports < ActiveRecord::Migration[5.2]
  def change
    create_table :member_imports do |t|
      t.references :plan, foreign_key: true
      t.json :problems

      t.timestamps
    end
  end
end
