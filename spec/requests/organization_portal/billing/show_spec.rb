describe 'Order', type: :request do
  let(:order) { orders(:metova_credit) }
  let(:organization) { organizations(:bridge) }
  as { users(:joseph) }

  describe 'show' do
    before do
      organizations(:bridge).users << users(:joseph)
      users(:joseph).organizations = [organization]
      visit organization_order_path(organization, order)
    end

    it 'shows details for an order' do
      expect(page).to have_content t('orders.order_header.bill_to')
      expect(page).to have_content order.address.street1
      expect(page).to have_content order.address.street2
      expect(page).to have_content order.address.city
      expect(page).to have_content order.address.state
      expect(page).to have_content order.address.zip
      expect(page).to have_content t('orders.order_header.invoice_date')
      expect(page).to have_content l(order.created_at, format: :mmddyyyy)
      expect(page).to have_content t('orders.order_header.terms')
      expect(page).to have_content t('orders.order_header.terms_verbiage')
      expect(page).to have_content t('orders.order_header.due_date')
      expect(page).to have_content l(order.starts_on, format: :mmddyyyy)
      expect(page).to have_content t('orders.order_header.purchase_order')
      expect(page).to have_content order.po_number
    end

    it 'displays each product purchased' do
      expect(page).to have_content t('orders.show.quantity')
      expect(page).to have_content t('orders.show.description')
      expect(page).to have_content t('orders.show.amount')
      order.plan_product_categories.each do |product|
        expect(page).to have_content(product.product_category.name)
        expect(page).to have_content((product.product_category.product_fee * order.members_count).to_format)
      end
    end

    it 'displays details for the order' do
      expect(page).to have_content t('orders.order_details.thank_you')
      expect(page).to have_content t('orders.order_details.paid_with_credit')
      expect(page).to have_content t('orders.order_details.credit_info', acct_number: order.payment_method.credit_card_number)
      expect(page).to have_content t('orders.order_details.order_processing')
      expect(page).to have_content t('orders.order_details.subtotal')
      expect(page).to have_content t('orders.order_details.administration_fee')
      expect(page).to have_content t('orders.order_details.credits')
      expect(page).to have_content t('orders.order_details.total_invoice')
      expect(page).to have_content t('orders.order_details.total_due')
      expect(page).to have_content (-order.total_credits).format
      expect(page).to have_content order.total_charges.format
      expect(page).to have_content order.total_fees.format
      expect(page).to have_content order.total.format
      expect(page).to have_content order.balance_due.format
    end

    it 'has a link to return back to the orders' do
      expect(page).to have_link I18n.t('orders.show.nav.back'), href: organization_orders_path(organization)
    end

    it 'has a button to print the order' do
      expect(page).to have_button I18n.t('orders.show.print_button')
    end
  end
end
