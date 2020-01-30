class FileMustBeAttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :must_be_attached) unless value.attached?
  end
end
