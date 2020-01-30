class CreditPurchasePolicy < ApplicationPolicy
  # TODO: need user policy for Credit Purchases
  def create?
    true
  end

  def new?
    true
  end

  def index?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def void?
    true
  end

  def print?
    true
  end

  def pay?
    true
  end

  def export?
    edit?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        user.organizations.merge(scope.all)
      end
    end
  end
end
