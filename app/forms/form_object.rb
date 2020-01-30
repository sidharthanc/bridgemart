class FormObject
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include Rails.application.routes.url_helpers
end
