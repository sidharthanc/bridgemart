class AddDeactivatedEmailSentAtToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :codes, :deactivated_email_sent_at, :datetime
  end
end
