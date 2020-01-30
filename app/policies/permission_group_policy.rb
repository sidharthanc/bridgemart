class PermissionGroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.merge(PermissionGroup.where(id: user.owned_permission_groups)
        .or(PermissionGroup.where(id: user.permission_groups)))
    end
  end
end
