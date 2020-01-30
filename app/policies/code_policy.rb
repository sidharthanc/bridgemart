class CodePolicy < ApplicationPolicy
  def lock?
    !record.locking? && !record.locked?
  end

  def unlock?
    record.locking? || record.locked?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
