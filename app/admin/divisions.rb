ActiveAdmin.register Division do
  permit_params :name, :logo

  form partial: 'form'

  show do
    attributes_table do
      row :name
      row :logo do |division|
        attached_image_tag(division.logo)
      end
    end
  end
end
