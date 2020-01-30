class MemberPolicy < ApplicationPolicy
  def resend?
    edit?
  end

  def balance_inquiry?
    edit?
  end

  def reactivate?
    !deactivate?
  end

  def scope
    Pundit.policy_scope!(user, Member)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        user.organization_members.merge(scope.all)
      end
    end
  end
end
