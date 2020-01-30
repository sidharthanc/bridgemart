class MigrateImageNameToImageOnProductCategories < ActiveRecord::Migration[5.2]
  def up
    ProductCategory.find_each do |product_category|
      image_name = "#{product_category.image_name}-gray.png"
      product_category.image.attach(
        io: image(image_name),
        filename: image_name
      )
    end
  end

  def image(image_name)
    File.open Rails.root.join('app', 'assets', 'images', image_name)
  end

  def as_gray_png(image_name)
    "#{image_name}-gray.png"
  end
end
