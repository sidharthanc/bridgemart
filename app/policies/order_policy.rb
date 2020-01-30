class OrderPolicy < ApplicationPolicy
  def confirm?
    create?
  end

  def process_order?
    create?
  end

  def add?
    create?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope
      elsif user
        user.orders.merge(scope.all)
      else
        scope.none
      end
    end
  end
end
