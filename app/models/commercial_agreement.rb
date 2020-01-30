class CommercialAgreement < ApplicationRecord
  before_save :preserve_old_filename

  has_many :signatures
  has_many :organizations, through: :signatures
  belongs_to :organization, optional: true
  has_one_attached :pdf

  scope :with_organization, lambda { |id = nil|
    where(organization_id: id)
  }

  audited

  private
    def preserve_old_filename
      self.audit_comment = Rails.application.routes.url_helpers.rails_blob_path(pdf, only_path: true) if persisted?
    end
end
