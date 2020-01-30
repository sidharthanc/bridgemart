class ReplacePlanWithOrderInInvoices < ActiveRecord::Migration[5.2]
  def up
    add_reference :invoices, :order, index: true

    update_invoices_with_latest_orders

    remove_column :invoices, :plan_id
  end

  def down
    add_reference :invoices, :plan, index: true

    update_invoices_with_latest_plans

    remove_column :invoices, :order_id
  end

  def update_invoices_with_latest_orders
    # Invoice.find_each do |invoice|
    #  invoice.update order: invoice.plan.orders.last
    # end
  end

  def update_invoices_with_latest_plans
    # Invoice.find_each do |invoice|
    #  invoice.update plan: invoice.order.plan
    # end
  end
end
