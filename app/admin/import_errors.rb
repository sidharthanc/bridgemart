ActiveAdmin.register ImportError do
  actions :index, :show

  filter :full_filepath
  filter :error_message
  filter :csv_row_number
  filter :csv_record
  filter :created_at
  filter :updated_at
  filter :status_or_card_id_or_inactive_or_rail_type_or_invoice_id_or_card_amount_or_employer_id_or_company_name_or_invoice_date_or_date_assigned_or_email_address_or_date_fulfilled_or_enrollment_type_or_employee_by_member_or_remaining_balance_or_eml_actual_usage_or_card_number_or_employee_by_member_id_or_purchase_instructions_contains, as: :string, label: "CSV RECORD"

  index do
    column(:id)
    column(:full_filepath)
    column(:error_message)
    column(:csv_row_number)
    column(:csv_record)
    column(:created_at)
    column(:updated_at)
    actions
  end

  show do
    attributes_table do
      row(:id)
      row(:full_filepath)
      row(:error_message)
      row(:csv_row_number)
      row(:csv_record) { "<pre>#{JSON.pretty_generate import_error.csv_record}</pre>".html_safe }
      row(:created_at)
    end
  end
end
