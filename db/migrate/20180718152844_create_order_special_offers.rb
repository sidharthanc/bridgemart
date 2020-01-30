class CreateOrderSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :orders, :special_offers do |t|
      t.index :order_id
      t.index :special_offer_id
    end
  end
end
