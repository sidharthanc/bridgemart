class ApplicationRecord < ActiveRecord::Base
  include Skylight::Helpers

  self.abstract_class = true

  def self.permission_target
    model_name.singular
  end

  def permission_target
    self.class.permission_target
  end

  def sum_monetized(relation, field)
    field = field.to_s + '_cents' unless field.to_s.include?('_cents')
    Money.new(relation.sum(field))
  end
end
