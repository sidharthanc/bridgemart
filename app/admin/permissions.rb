ActiveAdmin.register Permission do
  permit_params :target, :create_permitted, :update_permitted

  belongs_to :permission_group
  navigation_menu :permission_group

  form do |form|
    form.semantic_errors

    form.inputs do
      form.input :target, as: :select, collection: Permission::ALL_TARGETS
      form.input :create_permitted
      form.input :update_permitted
    end

    form.actions
  end
end
