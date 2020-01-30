module MassAssignable
  def prevent_unauthorized_mass_assignment!(attribute:, params:, scope:)
    unauthorized_ids = scope.where.not(id: authorized(scope)).ids
    authorized_ids = authorized(scope.unscoped.where(id: params[attribute])).ids

    params[attribute] = authorized_ids | unauthorized_ids
  end
end
