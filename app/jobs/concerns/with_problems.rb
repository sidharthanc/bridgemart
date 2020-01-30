module WithProblems
  extend ActiveSupport::Concern

  def problems_for(record, index:)
    record.errors.details.to_h.merge(index: index, errors: record.errors.to_a)
  end
end
