class PaymentMethodPolicy < ApplicationPolicy
  def confirm?
    edit?
  end
end
