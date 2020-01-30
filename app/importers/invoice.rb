class Invoice < Importer
  private
    def create_schema_records(record)
      @record = record
      create_plan
      create_line_items if create_order
    end

    def organization
      @organization = Organization.find_by legacy_identifier: employer_id
      @organization ||= Organization.find_by! legacy_identifier: employer_id_without_location
      @organization
    end

    def create_plan
      return unless plan.nil?

      @plan = Plan.create! organization_id: organization.id
    end

    def plan
      @plan = organization.plans&.last
    end

    def create_order
      @order = Order.find_by legacy_identifier: invoice_id
      if @order
        log_exception RuntimeError.new('Order already exists'), @record
        return
      end
      @order = Order.create! order_params
    end

    def order_params
      {
        legacy_identifier: invoice_id,
        created_at: invoice_date,
        paid_at: payment_date,
        plan_id: plan.id,
        starts_on: invoice_date,
        started_at: payment_date.present? ? invoice_date : nil,
        ends_on: ending_date,
        paid: payment_date.present? ? true : false,
        po_number: po_number
      }
    end

    def po_number
      location = @record.fetch('Location')
      po = @record.fetch('PO Number')
      [location, po].without(nil, '').join(' -- ')
    end

    def create_line_items
      create_line_item_charge
      create_line_item_fee
      create_line_item_credit
    end

    def ending_date
      invoice_date + 1.year
    end

    def create_line_item_fee
      return unless fee?

      LineItem.create! order: @order, charge_type: :fee, amount_cents: fee, source: organization, quantity: item_count
    end

    def create_line_item_charge
      return unless charge?

      LineItem.create! order: @order, charge_type: :charge, amount_cents: charge, source: organization, quantity: item_count
    end

    def create_line_item_credit
      return unless credit?

      LineItem.create! order: @order, charge_type: :credit, amount_cents: credit, source: organization
    end

    def fee
      @record.fetch('Administration Fee').to_f * 100
    end

    def charge
      @record.fetch('Sub-Total').to_f * 100
    end

    def credit
      @record.fetch('Credits').to_f * 100
    end

    def item_count
      @record.fetch('Count - Line Items').to_i
    end

    def fee?
      !fee.zero?
    end

    def charge?
      !charge.zero?
    end

    def credit?
      !credit.zero?
    end

    def employer_id
      location_id = @record.fetch('Location ID')
      employer_id = employer_id_without_location
      [employer_id, location_id].without(nil, '').join('-')
    end

    def employer_id_without_location
      @record.fetch('Employer ID')
    end

    def invoice_id
      @record.fetch('Invoice ID')
    end

    def invoice_date
      Date.strptime(@record.fetch('Invoice Date'), '%m/%d/%Y')
    end

    def status
      @record.fetch('Status')
    end

    def payment_date
      date = @record.fetch('Payment Date')
      if date.present?
        Date.strptime(@record.fetch('Payment Date'), '%m/%d/%Y')
      elsif status == 'Fulfilled'
        date = invoice_date
      end
      date
    end
end
