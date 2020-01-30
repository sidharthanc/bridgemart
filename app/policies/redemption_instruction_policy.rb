class RedemptionInstructionPolicy < ApplicationPolicy
  def index?
    super || user.organizations.include?(record.organization)
  end

  def destroy?
    user.admin? || user.organizations.include?(record.organization)
  end

  def show?
    super && (user.admin? || user.organizations.include?(record.organization))
  end
end
