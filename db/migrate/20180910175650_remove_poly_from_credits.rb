class RemovePolyFromCredits < ActiveRecord::Migration[5.2]
  def up
    add_reference :credits, :organization, foreign_key: true, index: true

    Credit.all.each do |credit|
      credit.update organization_id: credit.creditable_id
    end

    remove_reference :credits, :creditable, polymorphic: true
  end

  def down
    add_reference :credits, :creditable, polymorpic: true

    Credit.all.each do |credit|
      credit.update creditable: credit.organization
    end

    remove_reference :credits, :organization, foreign_key: true, index: true
  end
end
