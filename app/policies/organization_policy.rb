class OrganizationPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def manage?
    user.admin? || owned?
  end

  def update?
    super && manage?
  end

  def destroy?
    user.admin?
  end

  def index?
    true
  end

  def show?
    user.admin? || owned?
  end

  protected
    def owned?
      @owned ||= user.organizations.include?(record)
    end

    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          user.organizations
        end
      end
    end
end
