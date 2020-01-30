class ImportError < ApplicationRecord
  ransacker :status do |parent|
    csv_record_search(parent, 'Status')
  end
  ransacker :card_id do |parent|
    csv_record_search(parent, 'Card ID')
  end
  ransacker :inactive do |parent|
    csv_record_search(parent, 'Inactive')
  end
  ransacker :rail_type do |parent|
    csv_record_search(parent, 'Rail Type')
  end
  ransacker :invoice_id do |parent|
    csv_record_search(parent, 'Invoice ID')
  end
  ransacker :card_amount do |parent|
    csv_record_search(parent, 'Card Amount')
  end
  ransacker :employer_id do |parent|
    csv_record_search(parent, 'Employer ID')
  end
  ransacker :company_name do |parent|
    csv_record_search(parent, 'Company Name')
  end
  ransacker :invoice_date do |parent|
    csv_record_search(parent, 'Invoice Date')
  end
  ransacker :date_assigned do |parent|
    csv_record_search(parent, 'Date Assigned')
  end
  ransacker :email_address do |parent|
    csv_record_search(parent, 'Email Address')
  end
  ransacker :date_fulfilled do |parent|
    csv_record_search(parent, 'Date Fulfilled')
  end
  ransacker :enrollment_type do |parent|
    csv_record_search(parent, 'Enrollment Type')
  end
  ransacker :employee_by_member do |parent|
    csv_record_search(parent, 'Employee / Member')
  end
  ransacker :remaining_balance do |parent|
    csv_record_search(parent, 'Remaining Balance')
  end
  ransacker :eml_actual_usage do |parent|
    csv_record_search(parent, 'EML - Actual Usage')
  end
  ransacker :card_number do |parent|
    csv_record_search(parent, 'Card Number (Export)')
  end
  ransacker :employee_by_member_id do |parent|
    csv_record_search(parent, 'Employee / Member ID')
  end
  ransacker :purchase_instructions do |parent|
    csv_record_search(parent, 'Purchase Instructions')
  end

  def self.csv_record_search(parent, column_name)
    Arel::Nodes::InfixOperation.new('->>', parent.table[:csv_record], Arel::Nodes.build_quoted(column_name))
  end
end
