class ServiceActivityPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
