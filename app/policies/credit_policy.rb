class CreditPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def export?
    true
  end
end
