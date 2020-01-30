class ProductCategoryPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def activate?
    user.admin?
  end

  def deactivate?
    user.admin?
  end
end
