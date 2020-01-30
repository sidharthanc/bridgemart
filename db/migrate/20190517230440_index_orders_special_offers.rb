class IndexOrdersSpecialOffers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :orders_special_offers, %i[order_id special_offer_id], algorithm: :concurrently
  end
end
