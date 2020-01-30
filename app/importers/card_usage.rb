class CardUsage < Importer
  private
    def create_schema_records(record)
      @record = record
      create_usage
    end

    def code
      @code = Code.find_by! legacy_identifier: card_legacy_identifier
    end

    def card_legacy_identifier
      @record.fetch('Card ID')
    end

    def create_usage
      @usage = Usage.new usage_params
      usage = Usage.find_by(transaction_detail_identifier: @usage.transaction_detail_identifier)
      if usage
        log_exception RuntimeError.new('Usage (Transaction Details ID) already exists'), @record
        return
      end
      @usage.save!
    end

    def usage_params
      {
        used_at: visit_date,
        visit_number: @record.fetch('visit_nbr'),
        store_city: @record.fetch('store_city'),
        store_state: @record.fetch('store_state'),
        store_number: @record.fetch('store_nbr'),
        department_category: @record.fetch('dept_catg'),
        upc_number: @record.fetch('upc_nbr'),
        upc_description: @record.fetch('upc_desc'),
        company_type: @record.fetch('Company Type'),
        transaction_detail_identifier: @record.fetch('Transaction Details ID'),
        external_id: clean_external_id,

        amount_cents: retail_price,
        total_usage_cents: in_cents('total usage'),
        total_per_visit_cents: in_cents('Total Per Visit'),
        retail_price_cents: retail_price,

        code_id: code.id
      }
    end

    def in_cents(key)
      @record.fetch(key).to_f * 100
    end

    def visit_date
      convert_to_date @record.fetch('visit_date')
    end

    def convert_to_date(string)
      string.blank? ? Date.current : Date.strptime(string, '%m/%d/%Y')
    end

    def clean_external_id
      @record.fetch('Card Number (export)')&.gsub(/^'/, '')
    end

    def retail_price
      in_cents('retail_price')
    end
end
