class AddNumberOfEmployeesWithRxSafteyEyewearToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :number_of_employees_with_safety_rx_eyewear, :string
  end
end
