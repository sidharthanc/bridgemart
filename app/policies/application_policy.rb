class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.admin?
  end

  def show?
    scope.exists? id: record.id
  end

  def create?
    Rails.cache.fetch("permissions/#{user.cache_key}/#{record.permission_target}/create", expires_in: 1.hour) do
      permissions.update_permitted.exists?
    end
  end

  def new?
    create?
  end

  def update?
    Rails.cache.fetch("permissions/#{user.cache_key}/#{record.permission_target}/update", expires_in: 1.hour) do
      permissions.update_permitted.exists?
    end
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def deactivate?
    record.active? && update?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def permissions
    return Permission.none unless user

    Rails.cache.fetch("permissions/#{user.cache_key}/#{record.permission_target}", expires_in: 1.hour) do
      Permission.in_permission_groups(user.permission_groups)
                .targeting(record.permission_target)
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
