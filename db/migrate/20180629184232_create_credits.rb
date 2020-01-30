class CreateCredits < ActiveRecord::Migration[5.2]
  def change
    create_table :credits do |t|
      t.references :creditable, polymorphic: true
      t.references :source, polymorphic: true
      t.monetize :amount

      t.timestamps
    end
  end
end
