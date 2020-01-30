class MoveImageColumnDataToIconColumn < ActiveRecord::Migration[5.2]
  def up
    ProductCategory.find_each do |product_category|
      product_category.icon.attach io: StringIO.new(product_category.image.download),
                         filename: product_category.image.filename,
                         content_type: product_category.image.content_type
      product_category.save!
    end
  end

  def down
    ProductCategory.find_each do |product_category|
      product_category.icon.purge
    end
  end
end
