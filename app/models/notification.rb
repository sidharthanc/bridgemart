class Notification < ApplicationRecord
  audited
  validates :sent_to, :template_id, presence: true
end
