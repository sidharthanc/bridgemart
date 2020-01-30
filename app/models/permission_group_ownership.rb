class PermissionGroupOwnership < ApplicationRecord
  belongs_to :permission_group
  belongs_to :owner, class_name: 'PermissionGroup'
end
