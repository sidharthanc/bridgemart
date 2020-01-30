class UsageExport
  def initialize(usages)
    @usages = usages
  end

  def filename
    "usages-#{Date.current}"
  end

  def csv
    CSV.generate(headers: true) do |csv|
      csv << column_headers
      @usages.each do |usage|
        csv << usage_and_member(usage)
      end
    end
  end

  private
    def usage_and_member(usage)
      [
        usage.code_id,
        usage.code.order.id,
        usage.created_at.to_date,
        usage.used_at.to_date,
        usage.visit_number,
        usage.store_city,
        usage.store_state,
        usage.total_per_visit,
        usage.retail_price,
        usage.store_number,
        usage.department_category,
        usage.upc_number,
        usage.upc_description,
        usage.company_type,
        usage.member,
        Member.find(usage.member).name,
        nil
      ]
    end

    def column_headers
      headers = %w[code_id order created_at used_at visit_number store_city store_state total_per_visit retail_price store_number department_category upc_number upc_description company_type member member_name bridge_usage]

      headers.map do |col|
        I18n.t("usages.index.columns.#{col}")
      end
    end
end
