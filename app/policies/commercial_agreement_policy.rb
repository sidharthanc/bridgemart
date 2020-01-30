class CommercialAgreementPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def edit?
    false
  end

  def update?
    false
  end
end
