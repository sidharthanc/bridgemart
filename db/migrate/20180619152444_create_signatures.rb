class CreateSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :signatures do |t|
      t.references :organization
      t.references :commercial_agreement
      t.timestamps
    end

    remove_reference :plans, :commercial_agreement, index: true
  end
end
