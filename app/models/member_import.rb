class MemberImport < ApplicationRecord
  belongs_to :order
  has_one :plan, through: :order
  has_one_attached :file

  scope :unacknowledged, -> { where(acknowledged: false) }

  def errors?
    problems?
  end

  def acknowledge!
    update acknowledged: true
  end

  def humanized_problems
    return [] unless problems?

    problems.map { |problem| "Row #{problem['index'] + 1}: #{problem['errors'].join(', ')}" }
  end

  def start_import
    Enrollment::MemberImportJob.perform_later self
  end
end
