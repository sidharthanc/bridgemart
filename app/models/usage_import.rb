class UsageImport < ApplicationRecord
  has_one_attached :file
  validates :file, file_must_be_attached: true
end
